pipeline {
    agent { label 'docker' }

    post {
        always {
            sh "docker-compose --project-name $BUILD_TAG --file tools/docker/onec/docker-compose.yml down || :"
            junit allowEmptyResults: true, testResults: '**/tests*.xml'
        }
    }

    options { 
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 90, unit: 'MINUTES')
        timestamps() 
    }

    stages {

        stage('onec prepare') {
            steps {
                sh 'docker-compose --file  tools/docker/onec/docker-compose.yml pull'
                sh "docker-compose --project-name $BUILD_TAG --file  tools/docker/onec/docker-compose.yml up -d"
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
