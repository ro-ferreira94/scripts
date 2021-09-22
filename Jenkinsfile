pipeline {
    agent any
    stages {
        stage('pegando o codigo no git') {
            steps {
                git url: 'https://github.com/ro-ferreira94/scripts.git' , branch: 'master'
            }
        }
        stage('OLA!') {
            steps {
                echo "Executando shell"
            }
        }
        stage('Comando Shell') {
            steps {
                sh '/Users/rodrigo.ferreira/scripts/def.py'
            }
        }
    }
}