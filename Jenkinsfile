pipeline {
    agent any

    parameters {
        gitParameter branchFilter: 'origin/(.*)', defaultValue: 'origin/master', name: 'BRANCH', type: 'PT_BRANCH', description: 'Select the Git branch to build'
        booleanParam(defaultValue: false, description: 'Set true to perform Maven build', name: 'mvn_build')
        booleanParam(defaultValue: false, description: 'Set true to publish artifacts to Nexus', name: 'publish_to_nexus')
    }

    tools {
        maven "Maven"  // Must match Jenkins Global Tool Configuration exactly
    }

    environment {
        NEXUS_VERSION = "nexus3"
        NEXUS_PROTOCOL = "http"
        NEXUS_URL = "52.23.219.98:8081"
        NEXUS_REPOSITORY = "maven-snapshots"
        NEXUS_CREDENTIAL_ID = "nexus_credentials"
    }

    stages {
        stage("Clone Code") {
            steps {
                script {
                    git branch: "${params.BRANCH.replace('origin/', '')}", url: 'https://github.com/mubeen-hub78/spring3-mvc-maven-xml-hello-world-1.git'
                }
            }
        }

        stage("Maven Build") {
            steps {
                script {
                    if (params.mvn_build) {
                        echo "Starting Maven build..."
                        sh 'mvn -Dmaven.test.failure.ignore clean package'
                    } else {
                        echo "Maven build skipped as 'mvn_build' parameter is false."
                    }
                }
            }
        }

        stage("Publish to Nexus") {
            steps {
                script {
                    if (params.publish_to_nexus) {
                        def pom = readMavenPom file: "pom.xml"
                        def filesByGlob = findFiles(glob: "target/*.${pom.packaging}")

                        if (filesByGlob.size() > 0) {
                            def artifactPath = filesByGlob[0].path

                            echo "*** Found artifact file: ${artifactPath}"
                            echo "*** GroupId: ${pom.groupId}, Packaging: ${pom.packaging}, Version: ${pom.version}"

                            nexusArtifactUploader(
                                nexusVersion: NEXUS_VERSION,
                                protocol: NEXUS_PROTOCOL,
                                nexusUrl: NEXUS_URL,
                                groupId: pom.groupId,
                                version: "${BUILD_NUMBER}",
                                repository: NEXUS_REPOSITORY,
                                credentialsId: NEXUS_CREDENTIAL_ID,
                                artifacts: [
                                    [
                                        artifactId: pom.artifactId,
                                        classifier: '',
                                        file: artifactPath,
                                        type: pom.packaging
                                    ],
                                    [
                                        artifactId: pom.artifactId,
                                        classifier: '',
                                        file: "pom.xml",
                                        type: "pom"
                                    ]
                                ]
                            )
                        } else {
                            error "*** No artifact found in target directory with packaging: ${pom.packaging}"
                        }
                    } else {
                        echo "Publish to Nexus skipped as 'publish_to_nexus' parameter is false."
                    }
                }
            }
        }
    }
}
