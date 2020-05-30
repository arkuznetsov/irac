pipeline {
    agent { label 'docker' }

    post {
        always {
            script{ 
                def secrets = [
                    [path: "DevOps/RELEASE_VERSIONS", engineVersion: 2, secretValues: [
                        [envVar: 'ONEC_VERSION', vaultKey: 'ONEC']
                    ]],
                    [path: "DevOps/ONEC_RELEASE", engineVersion: 2, secretValues: [
                        [envVar: 'ONEC_USERNAME', vaultKey: 'user'],
                        [envVar: 'ONEC_PASSWORD', vaultKey: 'password']]]
                ] 
                withVault([configuration: [timeout: 60], vaultSecrets: secrets ]){   
                    sh "docker-compose --project-name $BUILD_TAG --file tools/docker/onec/docker-compose.yml down" 
                }
            } 
            junit allowEmptyResults: true, testResults: '**/tests*.xml'
        }
    }

    options { 
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 90, unit: 'MINUTES')
        timestamps() 
    }

    environment {
        ONEC_VERSION = vault path: "DevOps/RELEASE_VERSIONS", key: 'ONEC'
    }

    stages {

        stage('onec prepare') {
            steps { 
                script{ 
                    
                    def secrets = [
                        [path: "DevOps/ONEC_RELEASE", engineVersion: 2, secretValues: [
                            [envVar: 'ONEC_USERNAME', vaultKey: 'user'],
                            [envVar: 'ONEC_PASSWORD', vaultKey: 'password']]]
                    ] 
                    withVault([configuration: [timeout: 60], vaultSecrets: secrets ]){   
                        sh 'docker-compose --file  tools/docker/onec/docker-compose.yml pull'
                        sh "docker-compose --project-name $BUILD_TAG --file  tools/docker/onec/docker-compose.yml up -d" 
                    }
                }   
            }
        }

        stage('BDD testing') {
            steps {
                echo 'Starting to build docker image'
                script {  
                    def secrets = [
                        [path: "infastructure/gitlab", engineVersion: 2, secretValues: [
                            [envVar: 'CI_BOT_TOKEN', vaultKey: 'ci-bot']
                        ]]]           
                    withVault([configuration: [timeout: 60], vaultSecrets: secrets ]){ 
                        withDockerContainer(args: "--network ${BUILD_TAG}_onec-net", image: 'registry.oskk.1solution.ru/docker-images/onec-oscript:8.3.14.1993-1.3.0') {
                            sh '''1bdd exec -junit-out tests_bdd.xml ./features '''
                        }
                    }
                }          
            }
        }

        stage('TDD testing') {
            steps {
                echo 'Starting to build docker image'
                script {  
                    def secrets = [
                        [path: "infastructure/gitlab", engineVersion: 2, secretValues: [
                            [envVar: 'CI_BOT_TOKEN', vaultKey: 'ci-bot']
                        ]]]           
                    withVault([configuration: [timeout: 60], vaultSecrets: secrets ]){ 
                        withDockerContainer(args: "--network ${BUILD_TAG}_onec-net", image: 'registry.oskk.1solution.ru/docker-images/onec-oscript:8.3.14.1993-1.3.0') {
                            sh '1testrunner -runall ./tests xddReportPath .'
                        }
                    }
                }          
            }
        }
    }
}
