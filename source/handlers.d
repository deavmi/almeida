module handlers;

import app;
import vibe.vibe;
import libyggdrasil.libyggdrasil;
import std.net.curl;
import std.json;
import std.stdio;
import std.socket;
import std.string;
import collector;

void home(HTTPServerRequest request, HTTPServerResponse response)
{
	/* Render the template */
	response.render!("index.dt");
}


private string[] getKeys()
{
	return d.getKeys();
}

void peerlist(HTTPServerRequest request, HTTPServerResponse response)
{
	/* Fetch the peers list from Arceliar's node */
	string[] peers = d.getKeys();

	ulong offset = to!(ulong)(request.query["offset"]);
	peers = peers[offset..offset+10];

	/* Fetch node names */
	Address testNode = parseAddress("201:6c56:f9d5:b7a5:8f42:b1ab:9e0e:5169", 9090);
	YggdrasilPeer yggPeer = new YggdrasilPeer(testNode);
	
	/* Render the template */
	Collector collector = d;
	response.render!("peerlist.dt", peers, collector, yggPeer, offset);
}

void peerinfo(HTTPServerRequest request, HTTPServerResponse response)
{
	/* Fetch the key */
	/* TODO: Validate the key */
	string key = request.query["key"];

	Address testNode = parseAddress("201:6c56:f9d5:b7a5:8f42:b1ab:9e0e:5169", 9090);
	YggdrasilPeer yggPeer = new YggdrasilPeer(testNode);

	/* Fetch the node */
	YggdrasilNode yggNode = yggPeer.fetchNode(key);

	/* Fetch the NodeInfo */
	NodeInfo nodeInfo = yggNode.getNodeInfo();

	string ip, name, group, country, operator, nodeInfoJSON;

	if(nodeInfo)
	{
		/* TODO: Fix up yggdraisl library for this */
		ip = "nodeInfo.getAddress();";
		name = nodeInfo.getName();
		group = nodeInfo.getGroup();
		country = nodeInfo.getLocation();
		operator = nodeInfo.getContact();

		nodeInfoJSON = nodeInfo.getFullJSON().toPrettyString();
		
		writeln(request);
	}
	
	
	//response.writeBody(to!(string)(request));
	
	Collector collector = d;
	
	/* Render the template */
	response.render!("peerinfo.dt", key, ip, name, group, operator, country, nodeInfoJSON, collector);
}

void buildinfo(HTTPServerRequest request, HTTPServerResponse response)
{
	/* Fetch the key */
	/* TODO: Validate the key */
	string key = request.query["key"];

	Address testNode = parseAddress("201:6c56:f9d5:b7a5:8f42:b1ab:9e0e:5169", 9090);
	YggdrasilPeer yggPeer = new YggdrasilPeer(testNode);

	/* Fetch the node */
	YggdrasilNode yggNode = yggPeer.fetchNode(key);

	/* Fetch the NodeInfo */
	NodeInfo nodeInfo = yggNode.getNodeInfo();
	JSONValue nodeinfo = nodeInfo.getFullJSON();

	string name = nodeinfo["buildname"].str();
	string platform = nodeinfo["buildplatform"].str();
	string arch = nodeinfo["buildarch"].str();
	string _version = nodeinfo["buildversion"].str();
	
	//response.writeBody(to!(string)(request));
	
	
	/* Render the template */
	response.render!("buildinfo.dt", key, name, platform, arch, _version);
}

void builddb(HTTPServerRequest request, HTTPServerResponse response)
{
	/* Render the template */
	Collector collector = d;
	response.render!("builddb.dt", collector);
}

void about(HTTPServerRequest request, HTTPServerResponse response)
{
	/* Render the template */
	response.render!("about.dt", app.sourceCodeLink, app.moneroAddress, app._version);
}

void error(HTTPServerRequest request, HTTPServerResponse response, HTTPServerErrorInfo error)
{
	/* Render the template */
	response.render!("error.dt", error);
}


/**
* API Handler
*
* This handles all requests in `/api/*`
*/
void apiHandler(HTTPServerRequest request, HTTPServerResponse response)
{
	JSONValue resp;

	/* Path */
	writeln(request.path);


	resp["name"] = d.getPlatforms();
	response.writeBody(resp.toString());
}

/**
* API Handlers below
*/

/**
* Handler for `/api/builddb`
*
* This returns buid information in the format:
*
* platforms: [
				{ name: ' ', count: 0},
			],
			archs: [
				{ name: ' ', count: 0},
			],
			versions: [
				{ name: ' ', count: 0},
			],
*/
void getbuilddb(HTTPServerRequest request, HTTPServerResponse response)
{
	/* JSON response */
	JSONValue responseJSON;


	/* Get all the platforms */
	JSONValue[] platformBlocks;
	string[] platforms = d.getPlatforms();
	foreach(string platform; platforms)
	{
		JSONValue platformBlock;
		platformBlock["name"] = platform;
		platformBlock["count"] = d.getPlatformCount(platform);

		platformBlocks ~= platformBlock;
	}
	responseJSON["platforms"] = platformBlocks;

	/* Get all the architectures */
	JSONValue[] archBlocks;
	string[] archs = d.getArchs();
	foreach(string arch; archs)
	{
		JSONValue archBlock;
		archBlock["name"] = arch;
		archBlock["count"] = d.getArchCount(arch);

		archBlocks ~= archBlock;
	}
	responseJSON["archs"] = archBlocks;

	/* Get all the versions */
	JSONValue[] versionBlocks;
	string[] versions = d.getVersions();
	foreach(string _version; versions)
	{
		JSONValue versionBlock;
		versionBlock["name"] = _version;
		versionBlock["count"] = d.getVersionCount(_version);

		versionBlocks ~= versionBlock;
	}
	responseJSON["versions"] = versionBlocks;


	/* Write back response */
	response.writeBody(responseJSON.toString());
}

void getpeerinfo(HTTPServerRequest request, HTTPServerResponse response)
{
	/* JSON response */
	JSONValue responseJSON;

	

	/* Fetch the key */
	/* TODO: Validate the key */
	string key = request.query["key"];

	/* Fetch the NodeInfo */
	NodeInfo nodeInfo = d.getNodeInfo(key);


	if(nodeInfo)
	{
		if(nodeInfo.isWellFormed())
		{
			/* Set the response */
			JSONValue nodeInfoBlock;
			nodeInfoBlock["name"] = nodeInfo.getName();
			nodeInfoBlock["domain"] = nodeInfo.getGroup();
			nodeInfoBlock["location"] = nodeInfo.getLocation();
			nodeInfoBlock["contact"] = nodeInfo.getContact();
			nodeInfoBlock["nodeinfo"] = nodeInfo.getFullJSON();
			responseJSON["response"] = nodeInfoBlock;

			responseJSON["status"] = "ok";
		}
		else
		{
			responseJSON["status"] = "malformed";
		}
	}
	else
	{
		responseJSON["status"] = "timeout";
	}

	/* Write back response */
	response.writeBody(responseJSON.toString());
}

/**
* Checks if a node is online
*
* /api/pingnode?key=<key>
*/
void pingnode(HTTPServerRequest request, HTTPServerResponse response)
{
	/* JSON response */
	JSONValue responseJSON;

	/* Fetch the key */
	/* TODO: Validate the key */
	string key = request.query["key"];

	Address testNode = parseAddress("201:6c56:f9d5:b7a5:8f42:b1ab:9e0e:5169", 9090);
	YggdrasilPeer yggPeer = new YggdrasilPeer(testNode);

	/* Fetch the node */
	YggdrasilNode yggNode = yggPeer.fetchNode(key);

	/* Ping the node */
	responseJSON["online"] = yggNode.ping();

	/* Write the response */
	response.writeBody(responseJSON.toString());
}