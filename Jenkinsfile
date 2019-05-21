// based on
// https://support.cloudbees.com/hc/en-us/articles/115000088431-Create-a-Matrix-like-flow-with-Pipeline

def boards = [ "intel-a10soc-devkit", "enclustra-mercury-aa1-pe1" ]
def tasks = [:]

for(int i=0; i < boards.size(); i++) {
	def boardValue = boards[i]
	tasks["${boardValue}"] = {
		node {
			def board = boardValue
			println "Building for ${board}"
			println "Node=${env.NODE_NAME}"
			checkout scm
			sh '''#!/bin/bash
				source /local/ecad/setup.bash 18.1
				ls -l
				make ${board}
			'''
			archiveArtifacts "boards/${board}/output_files/*.sof,boards/${board}/output_files/*.rbf,boards/${board}/output_files/*.rpt,boards/${board}/*.qsys,boards/${board}/*.sopcinfo,boards/${board}/hps_isw_handoff/*,boards/${board}/*.dts*,boards/${board}/*.xml"
		}
	}
}

stage ("Matrix") {
	parallel tasks
}
