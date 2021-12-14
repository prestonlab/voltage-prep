﻿using UnityEngine;
using System.Collections;
using System.Xml;

//Logs to a file a configurable number of seconds
//What GO is subject to logging is settable, and
//is probably done by FPSChanger
public class Logger : MonoBehaviour {
	//
	//Highest level tag settings
	//
	
	//Which run is this?
	public int RunNumber = -1;

	//Name of subject
	public string SubjectName = "name not assigned";
	
	//Version number
	public string VersionString = "1.0";

	//
	//Other settings
	//

	//File to output to
	public string XmlLogOutput = "temp.xml";

	//Log timer interval
	public float LogTimeInterval = .8f;

	//
	//Private members
	//

	//Logging relevant state
	//

	//What GO should we log? This is the player and
	//is changed by the FPSChooser script
	private GameObject gameObjectToLog;

	//The goal the player is trying to move towards
	private Vector3 goalDestination;
	
	//The origin of each world
	private Vector3 relativeOrigin;

	//Other private state
	//

	//XmlWriter
	private XmlWriter m_writer;

	//Timer
	private Timer logTimer;

	//Are we currently inside a trial element?
	private bool inTrial = false;

	//Time take to find object
	private float timeStart;

	//
	//Public methods
	//

	//Called to start the recording of a trial
	public void StartTrial(Vector3 destination, GameObject trackme, Vector3 relOrigin){

		//Setup local state
		//
		gameObjectToLog = trackme;
		goalDestination = destination;
		relativeOrigin = relOrigin; // XXX DEBUG

		//Write a trial element
		//
		m_writer.WriteStartElement("trial");

		//Refer to an old log file for an idea
		//of what each printed thing means
		//
		m_writer.WriteAttributeString("goalx",
				(goalDestination.x - relativeOrigin.x).ToString());

		m_writer.WriteAttributeString("goaly",
				(goalDestination.z - relativeOrigin.z).ToString());

		m_writer.WriteAttributeString("pose",
				gameObjectToLog.transform.rotation.eulerAngles.y.ToString());

		m_writer.WriteAttributeString("startx",
				(gameObjectToLog.transform.position.x - relativeOrigin.x).ToString());

		m_writer.WriteAttributeString("starty",
				(gameObjectToLog.transform.position.z - relativeOrigin.z).ToString());

		m_writer.WriteAttributeString("starttime",
				(Time.time).ToString());

		//Setup timer; other state
		//
		inTrial = true;
		logTimer.SetTimer(LogTimeInterval);
		timeStart = Time.time;
	}

	//Ends a started trial
	public void EndTrial(int index = -1){

		//Write the no bs element
		//
		m_writer.WriteStartElement("done");
		m_writer.WriteAttributeString("time_elapsed", (Time.time - timeStart).ToString());
		if(index != -1)
			m_writer.WriteAttributeString("index", index.ToString());
		m_writer.WriteEndElement();//End no bs element

		m_writer.WriteEndElement();//End trial element

		inTrial = false;
	}

	public void StartPhase(string phase){
		m_writer.WriteStartElement(phase);
	}
	
	public void EndPhase(){
		m_writer.WriteEndElement();
	}

	//
	//Helper methods
	//

	//Log the state of the current frame
	private void WriteFrame(){
		//Writing this frame...
		m_writer.WriteStartElement("frame");

		//This is our relevant data:
		//
		Transform t = gameObjectToLog.transform;
        if(Vector3.Distance(t.position, goalDestination) < 10){
            Debug.LogError("Distance is hella small: " + goalDestination.ToString()); // XXX DEBUG
        }
		m_writer.WriteAttributeString("distance", Vector3.Distance(t.position, goalDestination).ToString());
		m_writer.WriteAttributeString("pose", t.rotation.eulerAngles.y.ToString());
		m_writer.WriteAttributeString("timestamp", Time.time.ToString());
		m_writer.WriteAttributeString("x", (t.position.x - relativeOrigin.x).ToString());
		m_writer.WriteAttributeString("y", (t.position.z - relativeOrigin.z).ToString());

		//Done!
		m_writer.WriteEndElement();
	}

	public void InitLogger(){
		//Xml
		//

		//Setup XmlWriter with indenting enabled (uses hot C# syntax for Object Initializer)
		//TODO Try/catch/finally
		m_writer = XmlWriter.Create(XmlLogOutput, new XmlWriterSettings(){Indent = true});

		//Start our document
		m_writer.WriteStartDocument();

		//Add some high level information
		m_writer.WriteStartElement("run");
		m_writer.WriteAttributeString("number", RunNumber.ToString());
		m_writer.WriteAttributeString("subject", SubjectName);
		m_writer.WriteAttributeString("version", VersionString);
	}

	public void LogDebug(string s){
		m_writer.WriteStartElement("run");
		m_writer.WriteEndElement();
	}

	//
	//Unity callbacks
	//

	void Awake(){
		//Setup timer
		logTimer = new Timer();
	}

	//Log whatever
	void Update(){
		if(inTrial && logTimer.isDone){
			WriteFrame();
			logTimer.SetTimer(LogTimeInterval);
		}
	}

	//TODO exceptions/using statements
	//Close our file and that kind of thing
	void OnDestroy(){
		if(inTrial)
			EndTrial();
		
		//End our document
		m_writer.WriteEndDocument();

		//Close file
		m_writer.Close();
	}
}

