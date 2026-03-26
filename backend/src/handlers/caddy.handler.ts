import fs from 'fs/promises';


/**
 *  generate caddy config for new app 
 * caddy file lies on server
 * @param deployId 
 * @param subdomain 
 * @param port 
 */

const generateCaddyConfig = async(deployId : string, subdomain:string, port : number)  =>  {
    const configPath = `etc/caddy/..`;
    // caddy config boilerplate
    const caddyConfig = ``;

    //write to filesystem
    

} 