import std.stdio;
import vibe.vibe;
import handlers;

void main()
{
	writeln("Starting almeida...");

	/* Create a router */
	URLRouter router = new URLRouter();

	/* Setup handlers */
	setupHandlers(router);

	/* Set listener information */
	HTTPServerSettings serverSettings = new HTTPServerSettings();
	
	/* TODO Make configurable from command-line */
	serverSettings.port = 9091;

	/* Bind the settings and the router toghether */
	listenHTTP(serverSettings, router);
	
	/* Start the webs erver loop */
	runApplication();
}

void setupHandlers(URLRouter router)
{
	/* TODO: Setup handlers here */
	router.get("/", &home);
	router.get("/peerdb", &peerlist);
	router.get("/peerinfo", &peerinfo);
	
}