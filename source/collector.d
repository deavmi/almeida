module collector;
import core.thread;
import core.sync.mutex;
import std.socket;
import std.net.curl;
import std.json;

public final class Collector : Thread
{
	private Address controlYgg;

	private string[] keys;
	private Mutex keysLock;

	this(Address controlYgg)
	{
		/* Set the worker function */
		super(&worker);
		
		/* Initialize the mutexes (lone star) */
		initMutexas();
	}

	private void worker()
	{
		while(true)
		{
			/* Refresh the PeerDB */
			refreshKeyDB();

			sleep(dur!("seconds")(500));
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