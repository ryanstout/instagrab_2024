const ProxyChain = require('proxy-chain');
const yargs = require('yargs/yargs');
const { hideBin } = require('yargs/helpers');

// Parse command line arguments
const argv = yargs(hideBin(process.argv))
    .option('local', {
        alias: 'l',
        description: 'Local port to listen on',
        type: 'number',
        default: 22225
    })
    .option('remote', {
        alias: 'r',
        description: 'Remote proxy URL',
        type: 'string',
        demandOption: true
    })
    .help()
    .alias('help', 'h')
    .argv;

const localPort = argv.local;
const remoteProxyUrl = argv.remote;
const newProxyUrl = `http://127.0.0.1:${localPort}`;

const server = new ProxyChain.Server({
    port: localPort,
    prepareRequestFunction: ({ request, username, password, hostname, port, isHttp }) => {
        return {
            requestAuthentication: false,
            upstreamProxyUrl: remoteProxyUrl,
        };
    },
});

server.listen(() => {
    console.log(`Proxy server is listening on ${newProxyUrl}`);
    console.log(`Forwarding to: ${remoteProxyUrl}`);
});

// Graceful shutdown
const closeServer = () => {
    console.log('Closing proxy server...');
    server.close(true)
        .then(() => {
            console.log('Proxy server closed.');
            process.exit(0);
        })
        .catch((err) => {
            console.error('Error while closing proxy server:', err);
            process.exit(1);
        });
};

process.on('SIGINT', closeServer);
process.on('SIGTERM', closeServer);