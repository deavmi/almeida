module app;

import std.stdio;
import vibe.vibe;
import handlers;
import collector;
import std.socket;

public Collector d;

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
	serverSettings.bindAddresses = ["::"];
	serverSettings.errorPageHandler = toDelegate(&error);

	/* Bind the settings and the router toghether */
	listenHTTP(serverSettings, router);

	/* Setup data collection */
	Address yggdrasilControlNode = parseAddress("201:6c56:f9d5:b7a5:8f42:b1ab:9e0e:5169", 9090);
	setupDataCollector(yggdrasilControlNode);
	
	/* Start the webs erver loop */
	runApplication();
}

void setupHandlers(URLRouter router)
{
	/* TODO: Setup handlers here */
	router.get("/", &home);
	router.get("/peerdb", &peerlist);
	router.get("/peerinfo", &peerinfo);
	router.get("/buildinfo", &buildinfo);
	router.get("/builddb", &builddb);
	router.get("/salazar", &buildinfo);
	router.get("/about", &about);
	
}

void setupDataCollector(Address nodeAddress)
{
	d = new Collector(nodeAddress);
	d.start();
}