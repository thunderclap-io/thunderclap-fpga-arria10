pipeline {
    agent any
    parameters {
        string(name: 'board', defaultValue: 'intel-a10soc-devkit', description: 'FPGA board to target')
    }
    stages {
        stage('Build') {
            steps {
		sh '''
			BOARD=${params.board}
	                echo "Building for $BOARD"
			source /local/ecad/setup.bash 18.1std
			make $BOARD
		'''
            }
        }
    }
}
