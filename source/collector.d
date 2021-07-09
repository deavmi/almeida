module collector;

import core.thread;
import core.sync.mutex;
import std.socket;
import std.net.curl;
import std.json;
import std.conv;
import std.stdio;
import libyggdrasil;
import std.string;


public final class Collector : Thread
{
	private Address controlYgg;

	private string[] keys;
	private Mutex keysLock;

	private NodeInfo[string] nodeInfos;
	private Mutex nodeInfosLock;

	private ulong[string] platforms;
	private ulong[string] archs;
	private ulong[string] versions;
	private Mutex popularityContestLock;

	this(Address controlYgg)
	{
		/* Set the worker function */
		super(&worker);

		/* Set the address of he admin socket */
		this.controlYgg = controlYgg;
		
		/* Initialize the mutexes (lone star) */
		initMutexas();
	}

	private void worker()
	{
		while(true)
		{
			/* Refresh the PeerDB */
			refreshKeyDB();

			/* Refresh PeerInfoDB */
			//refreshPeerInfoDB();

			/* Refresh BuildDB */
			refreshBuildDB();

			writeln("Cycle done");
			
			sleep(dur!("seconds")(500));
		}
	}

	private NodeInfo fetchNodeInfo(string key)
	{
		/* Get the control socket */
		YggdrasilPeer peer = new YggdrasilPeer(controlYgg);

		/* Get the Yggdrasil Node */
		YggdrasilNode node = peer.fetchNode(key);

		/* Fetch the NodeInfo */
		return node.getNodeInfo();
	}

	private void refreshPeerInfoDB()
	{
		/* Get all the keys */
		string[] keys = getKeys();

		/* Get the control socket */
		YggdrasilPeer peer = new YggdrasilPeer(controlYgg);

		/* Fetch all YggdrasilNode's */
		YggdrasilNode[] nodes;
		for(ulong i = 0; i < keys.length; i++)
		{
			/* The current key */
			string key = keys[i];
			writeln(key);
			writeln("PeerInfoDB: Fetching node "~to!(string)(i+1)~"/"~to!(string)(keys.length));
			nodes ~= peer.fetchNode(key);
		}

		/* Lock the list */
		nodeInfosLock.lock();

		/* Fetch all node infos and store them */
		foreach(YggdrasilNode node; nodes)
		{
			nodeInfos[node.getKey()] = node.getNodeInfo();
		}

		/* Unlock the list */
		nodeInfosLock.unlock();
	}

	private bool isKey(ulong[string] hashMap, string key)
	{
		foreach(string cKey; hashMap.keys)
		{
			if(cmp(cKey, key) == 0)
			{
				return true;
			}
		}

		return false;
	}

	public string[] getPlatforms()
	{
		popularityContestLock.lock();
		string[] platforms = platforms.keys;
		popularityContestLock.unlock();
		return platforms;
	}

	public ulong getPlatformCount(string key)
	{
		popularityContestLock.lock();
		ulong count = platforms[key];
		popularityContestLock.unlock();
		return count;
	}

	public string[] getArchs()
	{
		popularityContestLock.lock();
		string[] archs = archs.keys;
		popularityContestLock.unlock();
		return archs;
	}

	public ulong getArchCount(string key)
	{
		popularityContestLock.lock();
		ulong count = archs[key];
		popularityContestLock.unlock();
		return count;
	}

	public string[] getVersions()
	{
		popularityContestLock.lock();
		string[] versions = versions.keys;
		popularityContestLock.unlock();
		return versions;
	}

	public ulong getVersionCount(string key)
	{
		popularityContestLock.lock();
		ulong count = versions[key];
		popularityContestLock.unlock();
		return count;
	}


	private void refreshBuildDB()
	{
		/* Reset stats */
		archs = null;
		platforms = null;
		versions = null;
		
		/* Get all the keys */
		string[] keys = getKeys();

		/* Get the control socket */
		YggdrasilPeer peer = new YggdrasilPeer(controlYgg);

		/* Fetch all YggdrasilNode's */
		YggdrasilNode[] nodes;
		for(ulong i = 0; i < keys.length; i++)
		{
			/* The current key */
			string key = keys[i];
			writeln(key);
			writeln("BuildDB: Generating node "~to!(string)(i+1)~"/"~to!(string)(keys.length));
			nodes ~= peer.fetchNode(key);
		}

		ulong i = 0;
		foreach(YggdrasilNode node; nodes)
		{
			writeln("BuildDB: Fetching node information "~to!(string)(i+1)~"/"~to!(string)(nodes.length));
			NodeInfo nodeInfo = getNodeInfo(node.getKey());

			string arch = "unknown";
			string os = "unknown";
			string _version = "unknown";

			popularityContestLock.lock();
			
			/* If the NodeInfo fetch was successful */
			if(nodeInfo)
			{
				
				
				/* Whoever runs 221:c99a:91a1:cd2c:3164:27d7:9675:bf7d is a cunt
				* fucking no build info and i spent this much time, missing key crash
				*/
				try
				{
					JSONValue nodeInfoJSON = nodeInfo.getFullJSON();
				
					/* Fetch information */
					arch = nodeInfoJSON["buildarch"].str();
					os = nodeInfoJSON["buildplatform"].str();
					_version = nodeInfoJSON["buildversion"].str();

				}
				catch(JSONException e)
				{
					writeln("refreshBuildDB(): Missing some build info");
				}
			}
			else
			{
				writeln("refreshBuildDB(): Missing nodeinfo (timed out)");
				arch = "failed";
				os = "failed";
				_version = "failed";
			}

			if(!isKey(archs, arch))
			{
				archs[arch] = 0;
			}
			if(!isKey(platforms, os))
			{
				platforms[os] = 0;
			}
			if(!isKey(versions, _version))
			{
				versions[_version] = 0;
			}
												
			archs[arch]++;
			platforms[os]++;
			versions[_version]++;

			popularityContestLock.unlock();

			i++;
		}
	}

	private void refreshKeyDB()
	{
		keysLock.lock();

		string url = "http://[21e:e795:8e82:a9e2:ff48:952d:55f2:f0bb]/static/current";
			
		import std.net.curl;
		string k = cast(string)get(url);
		
		JSONValue json = parseJSON(k);
		json = json["yggnodes"];
		
		keys = json.object().keys;
		
		keysLock.unlock();
	}

	private void initMutexas()
	{
		keysLock = new Mutex();
		nodeInfosLock = new Mutex();
		popularityContestLock = new Mutex();
	}

	public NodeInfo getNodeInfo(string key)
	{

	//	writeln("getNodeInfo()");
		NodeInfo nodeInfo;
		
		/* Lock the list */
		nodeInfosLock.lock();

		/* Find Node (if exists) */
		foreach(NodeInfo nodeInfo; nodeInfos)
		{
			if(cmp(nodeInfo.getKey(), key) == 0)
			{
				nodeInfosLock.unlock();
				return nodeInfos[key];
			}
		}

		nodeInfosLock.unlock();

		nodeInfo = fetchNodeInfo(key);
		
		nodeInfosLock.lock();

		if(nodeInfo)
		{
			nodeInfos[key] = nodeInfo;	
		}
		

		nodeInfosLock.unlock();

		return nodeInfo;
	}
	
	public string[] getKeys()
	{
		string[] copiedKeys;
		keysLock.lock();

		foreach(string key; keys)
		{
			copiedKeys ~= key;
		}

		keysLock.unlock();

		return copiedKeys;
	}
	
}