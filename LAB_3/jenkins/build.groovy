import groovy.json.JsonSlurper
import groovy.json.JsonOutput

def GO_IMAGE = "192.168.99.100:5050/root/golang:1.23.5-alpine3.21"

def registryApi(String apiUrl, String credsId) {
    def response = ''
    withCredentials([usernamePassword(
        credentialsId: credsId,
        usernameVariable: 'REGISTRY_USER',
        passwordVariable: 'REGISTRY_PASS')]) {
        response = sh(
            script: "curl -s -u \${REGISTRY_USER}:\${REGISTRY_PASS} ${apiUrl}",
            returnStdout: true
        ).trim()
    }

    def json = new JsonSlurper().parseText(response)
    // echo "Found tags: ${json.tags.join(', ')}"
    return JsonOutput.prettyPrint(JsonOutput.toJson(json))
}

node {
    def registry    = "192.168.99.100:5050"
    def serviceName = "echo-server"
    def repoPath    = "adminforg"
    def imageName   = ""
    def imageTag    = ""
    def repoUrl     = "http://192.168.99.100:81/${repoPath}/${serviceName}.git"
    def registryUrl = "http://${registry}"

    def gitCredsId      = 'forgejo-userpass-credentials'
    def registryCredsId = 'docker-registry-credentials'

    try {
        stage("Prepare") {
            cleanWs()
            git url: repoUrl, credentialsId: gitCredsId, branch: 'main'

            env.GIT_COMMIT = sh(
                script: 'git rev-parse HEAD',
                returnStdout: true
            ).trim()

            imageTag = sh(
                script: "grep 'version' ./version.json | cut -d '\"' -f4",
                returnStdout: true
            ).trim()
            imageName = "${registry}/${repoPath}/${serviceName}"

            currentBuild.displayName = "# ${BUILD_NUMBER}-${serviceName}"
            currentBuild.description = "Version: ${imageTag}, Commit: ${GIT_COMMIT?.take(7)}"
        }

        stage("Build") {
            docker.withRegistry(registryUrl, registryCredsId) {
                docker.image(GO_IMAGE).inside {
                    stage("Compile") {
                        sh """
                            echo \$SHELL
                            ls -l
                            ./scripts/build.sh
                        """
                    }
                    stage("Tests") {
                        parallel(
                            unit: {
                                node {
                                    stage("Unit Tests") {
                                        echo "Running unit tests..."
                                        sh "echo 'STUB. unit-tests SUCCESS' | tee ./unit_tests_results.log"
                                    }
                                }
                            },
                            linter: {
                                node {
                                    stage("Linter") {
                                        echo "Running linter..."
                                        sh "./scripts/lint.sh || true"
                                    }
                                }
                            }
                        )
                    }
                }
            }
        }

        stage("Dockerize and push to registry") {
            docker.withRegistry(registryUrl, registryCredsId) {
                def customImage = docker.build("${imageName}:${imageTag}", ".")

                // push build tag
                customImage.push()
                // push latest
                customImage.push("latest")
            }
        }

        stage("Check registry") {
            script {
                def registryGetCatalog = "${registryUrl}/v2/_catalog"
                def registryGetTags = "${registryUrl}/v2/${repoPath}/${serviceName}/tags/list"

                println registryApi(registryGetCatalog, "docker-registry-credentials")
                println registryApi(registryGetTags, "docker-registry-credentials")
            }
        }
    } catch (e) {
        currentBuild.result = "FAILURE"
        echo "Build failed: ${e.message}"
        throw e
    } finally {
        stage('Finalize & Cleanup') {
            echo "Starting post-build cleanup..."

            sh "docker rmi ${imageName}:${imageTag} || true"
            sh "docker rmi ${imageName}:latest || true"

            cleanWs()
            echo "Cleanup finished."
        }
    }
}

