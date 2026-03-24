import { rejects } from 'assert';
import { error, log } from 'console';
import { resolve } from 'dns';
import Docker from 'dockerode';
import { logger } from 'hono/logger';
import Stream from 'stream';
const docker = new Docker();


const portBindings = {
    '3000/tcp' : [{HostPort : '3000'}],
}
//pull the image
const pullImage = async (imagename : string) : Promise<void> => {
    if(imagename == '') return ;

    return new Promise((resolve,reject) =>{

        docker.pull(imagename, function(err : Error, stream : NodeJS.ReadStream ) {
            if (err) {
                reject(err);
                return;
            }
            
            docker.modem.followProgress(stream , onProgress, onFinished);


            function onFinished(err: Error | null)  : void{
                if (err) {
                    console.error("error in pulling image");
                    reject(err)
                    
                } else {
                    console.log("image pullled succesfully");
                    resolve();
                }
            }
            function onProgress(event : any){
                if(event.status == "Dowloading"){
                    process.stdout.clearLine(0);
                    process.stdout.cursorTo(0);
                    process.stdout.write(event.progress);
                }else{
                    process.stdout.clearLine(0);
                    process.stdout.cursorTo(0);
                    process.stdout.write(event.status + "\n");
                }
            }
        }) 
        
    })


}




/**
 * build the cintainer
 * @param repourl
 * @param deployid
 */

    const createContainer = async (repoUrl : string, imageName: string, buildId : string) : Promise<Docker.Container> =>{
        //habdle repoerl amnndimage name uissues


        const container = await docker.createContainer({
            Image: imageName,
            name : `build ${buildId}`,
            AttachStderr: true,
            AttachStdin: false,
            AttachStdout: true,
            Tty: true,
            Cmd : [],
            ExposedPorts: { '80/tcp': {} },
            HostConfig: {
                PidsLimit:100,
                PortBindings: portBindings
                // for ci cd memory and cpu credentials
            },
            
        })

        return container;
    }