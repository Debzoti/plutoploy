import { exec } from "child_process";
import { log } from "console";
import path from "path";
import { promisify } from "util";

const execAsync = promisify(exec);

async function buildWorker(repoUrl: string): Promise<void> {
    console.log("Build worker started");

    const buildId = Date.now();
    const buildDir = `/tmp/builds/${buildId}`;
    const deployDir = `/var/www/apps/${buildId}`;

    try {
        //clone the repo
        await execAsync(`git clone --depth 1 ${repoUrl} ${buildDir}`);

        //install dependencies
        await execAsync(` cd ${buildDir} && npm install`);

        //build the app
        await execAsync(`cd ${buildDir} && npm run build`);

        //move to deploy dir
        await execAsync(`mkdir -p ${deployDir}`);
        await execAsync(`cp -r ${buildDir}/dist ${deployDir}`);

        //cleanup
        await execAsync(`rm -rf ${buildDir}`);
        
        console.log("Build worker completed");
    } catch (error : any) {
        console.error("build failed", error.message)
    }

}

const repoUrl = `https://github.com/Debzoti/react-jobs.git`

buildWorker(repoUrl)
    .then(() => {
        console.log("Build worker completed");
    })
    .catch((error : any) => {
        console.error("build failed", error.message)
    });