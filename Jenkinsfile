def sendEmailFailed(status,projectName,stage,devops_email,dev_name){
    emailext(
        attachLog: true,
        subject: "Jenkins Notification: Build ${status} at stage ${stage} of ${projectName} ",
        body: "<p> Attached is the log file of the ${env.JOB_NAME} [${env.BUILD_NUMBER}] pushed by ${dev_name} </p>",
        to: "${devops_email}"
    )
}

def sonarqube(projectName, projectKey){
	def sonarqubeScannerHome = tool name: 'sonar', type: 'hudson.plugins.sonar.SonarRunnerInstallation' 
	withSonarQubeEnv("sonarqube-server"){
		withCredentials([string(credentialsId: 'sonar', variable: 'sonar')]) {
			sh "npm install typescript"
			sh "${sonarqubeScannerHome}/bin/sonar-scanner -Dsonar.exclusions=dist/**,node_modules/**,env_to_secret.py,**/*.yaml   -Dsonar.host.url=http://sonarqube:9000 -Dsonar.login=${sonarLogin} -Dsonar.projectName=${projectName} -Dsonar.projectKey=${projectKey}"
		}
	}
}

def qualityGate(){
	sh "sleep 10"
	Integer maxRetry = 6
    for (i=0; i<maxRetry; i++){
    try {
        timeout(time: 10, unit: 'SECONDS') {
        def qg = waitForQualityGate()
        if (qg.status != 'OK') {
            error "Sonar quality gate status: ${qg.status}"
        	} 
        else {
            i = maxRetry
        	}
		}
	} catch(Exception e) {
        if (i == maxRetry-1) {
            throw e
            }
        }
    }
}

def dockerBuildPush(imageName){
	docker.withRegistry('https://index.docker.io/v1/', 'dockerhub') {
	def app = docker.build( "${imageName}", '.').push()
	}
	sh 'sleep 2'
	sh "docker rmi ${imageName}"
}

def deploymentK8s(commitId,deploymentName,imageName){
	withKubeConfig([credentialsId: 'kubernetesProd']) {
    	sh "kubectl apply -f k8s/secret.yaml"
		sh "cat k8s/deployment.yaml | sed 's/{{COMMIT_ID}}/${commitId}/g' | kubectl apply -f -"
		sh "kubectl annotate deployment ${deploymentName} kubernetes.io/change-cause='${imageName}' --record=false --overwrite=true"
		sh 'kubectl apply -f k8s/service.yaml'
	}
}
def test(){
	sh "echo Testing !!!! "
	def myTestContainer = docker.image('node:10')
    myTestContainer.pull()
    myTestContainer.inside { 	   
        sh 'npm install'
		sh 'npm run build-ts'
		sh 'export NODE_ENV=testCases && npm test'
    }
}

node {
    def commitId 
	def dev_email

    stage('SCM') {
		cleanWs()
        checkout scm 
        sh 'git rev-parse --short HEAD > .git/commit-id'
        commitId = readFile('.git/commit-id').trim()
		dev_email = sh(script: "git --no-pager show -s --format='%ae'", returnStdout: true).trim()
		dev_name = sh(script: "git --no-pager show -s --format='%an'", returnStdout: true).trim()		
        }
        
	def deploymentName = "my-service -n my-service"
	def imageName = "devil1211/my-service:${commitId}"
	def projectName = "my_services_prod"
	def projectKey = "My_Project"

    def PROJECT_NAME = 'My Service'

	if (env.BRANCH_NAME.startsWith("master")){
		try{
			stage('Test') {
                STAGE=env.STAGE_NAME
				test()
			}
			
			stage('Sonar-Scanner') {
                STAGE=env.STAGE_NAME
				sonarqube("${projectName}", "${projectKey}")
			}
				
			stage('Quality Gate'){
                STAGE=env.STAGE_NAME
				qualityGate()
			}
				
			stage('Docker Build/Push Cleanup') {
                STAGE=env.STAGE_NAME
				dockerBuildPush("${imageName}")
			}

			stage('Deployment') {
                STAGE=env.STAGE_NAME
				deploymentK8s("${commitId}", "${deploymentName}", "${imageName}")	
			}

			stage('Success'){
			    // send Mail If Pipeline succeeds
		} catch(error){
			// send Mail if Pipeline Fails
			sendEmailFailed('Failed',"${PROJECT_NAME}","${STAGE}","${dev_email}","${dev_name}")
		}
	}	
}
