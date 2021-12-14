# Voltage
[Short description] Voltage is a virtual world paradigm built in Unity to help test spatial perception and navigation ability in human ECoG participants.


## Getting Started - Prebuilt

These instructions will give you a copy of the project up and running on your local machine using the most up-to-date version of Voltage running on a pre-compiled Unity build. If you are interested in making changes to the project before running it, please refer to the [Getting Started - Custom Build](#getting-started---custom-build) instructions below.

### Prerequisites

Requirements for the experiment:
- [MATLAB v2018a](https://www.mathworks.com/products/matlab.html) - Header creation and experiment configuration are all done through MatLab. 
- [Python 2.7](https://www.python.org/downloads/release/python-2718/) - Python 2 is used to label data from Unity trials. Python isn't strictly necessary to run the experiment.
- [Psych Toolbox](http://psychtoolbox.org/) - Used to run some of the experiment tasks. 
- [Statistics and Machine Learning Toolbox]() - Used to create the header in MatLab. 

Though the software is largely built in Unity, to interact with this repository you will only need to use MATLAB, Python, and Psych Toolbox. The Unity build that is in this repository was tested on 13'' Macbook Airs using **MacOS Sierra** (10.12.6) and **El Capitan** (v10.11.6) with a display resolution of 1440x900. 

### Running the Experiment

First off, clone this repository to your local machine and open `MATLAB` to create the header for your experiment. Next, make sure to unzip `Build.zip`. You can leave it in the same directory as the zip file. This contains the Unity build needed to run this experiemnt. 

There is also a copy of the below instructions in this repository as a word document in `documents/voltage_experimenter_instructions`. You will also find some other helpful documents such as questionnaires and participant instructions. 

#### Setting up the Header
In `MATLAB`, make sure to change to the directory of where you cloned this repo. For example, 

```
cd ~/Experiments/voltage
```

Next, create the subject header with this command: 

```
voltage_header
```

You will be prompted to enter in the `Subject #`, `Subject Age`, and `Subject Gender`. 

Once entered and confirmed, you will have built your subject header. This will also create a folder in `/data` with all of your participant's configuration files. 

### Session 0

#### Free Roam Slow

From your terminal, run the following bash script: 

```
./voltage.sh [subject#] free_roam_slow 1 1
```

You'll see a popup from Unity asking for the run settings. Ensure that the screen resolution is set to `1440x900` and that the graphics quality is set to `Fantastic`. Next, click `Play!` and the experiment will begin. 

Once the participant is done roaming, hit `Command Q` to close Unity.

> Note: The participant needs to be comfortable with moving through the environment. It needs to be second nature to them. They shouldn’t be focusing on their movement or the controls; they need to be learning the object locations. It’s guaranteed they will try to cut this portion short (“OK, got it!). You should test them by having them move to the four corners of the environment (“how about you move to the corner to the left of the ship.”). Let them experience the boundaries within the environment, so they know they can’t just go anywhere. For some people this may seem like overkill, but this will save you time as
we progress. It’s for your benefit as well as to improve their performance.

#### Free Roam

In the terminal, load the voltage bash script

```
./voltage.sh [subject#] free_roam 1 1
```

#### Practice Study

As above, load the voltage bash script to begin the practice study portion. 

```
./volage.sh [subject#] prac_study 1 [run#]
```

There are 6 runs of this, so replace the `[run#]` with the correct interger for each run.

Validate that your resolution and graphics settings are the same as above and press "Play!" and the free roam will run. After completion, hit `Enter` in the terminal.

#### Practice Test

Next, run the experiment as before, in the terminal: 

```
./voltage.sh [subject#] prac_test 1 1
```

#### Practice Detection Task

In `MATLAB`, type: 

```
voltage_disp(hdr, "prac_disp", 1, 1, 1)
```

Once the intro is done, click `spacebar` to begin.

### Sessions 1 and 2

#### Detection Task Part 1

In `MATLAB`, load the first detection task as follows: 

```
voltage_disp(hdr, ‘disp’, [session#], 1, [run#])
```

The participant will be completing four runs of this task. Below, the `1` represents the first round of the detection task. For `run #`, you’ll have to input `1-4` as they move through the runs. `Session#` should be `1` (for the first non-practice session) or `2` (for the second non-practice session).

After the intro loads, click `spacebar` to begin. Repeat this step until all 4 runs are complete.
<!-- 
In this command, the second parameter is either a `1` or a `2` depending on if this is the `pre` or `post` portion of the experiment and the third parameter can be `1` through `4`. For this portion you will start with `1` as the third argument and then once it's done, enter `2` as the third argument. Repeat until you've finished with `4` as the third parameter and then move on to the next session.  -->

#### Study (Runs 1-3)

In your terminal window, execute the following script after replacing the necessary variables: 

```
./voltage.sh [subject#] study [session#] [run#]
```

Make sure that your Unity display settings are the same as described above, and hit play to run the learning phases. 

Repeat this step 3 times until all runs are complete. 

#### Test

In your terminal window, execute the following script after replacing the necessary variables: 

```
./voltage.sh [subject#] test [session#] 1
```

Hit `Play` to begin. 

#### Detection Task Part 2

In `MATLAB`, load the second detection task as follows: 

```
voltage_disp(hdr, ‘disp’, [session#], 2, [run#])
```

The participant will be completing four runs of this task. Below, the `1` represents the first round of the detection task. For `run #`, you’ll have to input `1-4` as they move through the runs. `Session#` should be `1` (for the first non-practice session) or `2` (for the second non-practice session).

After the intro loads, click `spacebar` to begin. Repeat this step until all 4 runs are complete.

That is all that's needed to run the experiment!


## Getting Started - Custom Build 

These instructions will give you a copy of the project up and running on your local machine and allow you to make any modifications to the codebase, or environments, that you like. This will allow you to create builds for newer Mac OS versions or Windows versions if you like. If you are only interested in running the experiment with the most recent build, please refer to the [Getting Started - Prebuilt](#getting-started---prebuilt) instructions above.

The original version of voltage was built with Unity 5.0.0f4 but this build was updated to allow for improved movement and the version was bumped to 2018.4.36f1 for long-term support and the ability to continue development on Mac computers running Catalina or higher. 

The Unity project itself reads from a text configuration file that is generated by MATLAB and runs accordingly. The guide below will describe how to edit the code or environments as well as what the configuration file contains. 

### Prerequisites

Requirements for the software and other tools to build:
- [Unity 3D v2018.4.36f1 LTS](https://unity3d.com/get-unity/download/archive) - This version can be downloaded using the archive or [Unity Hub](https://unity3d.com/get-unity/download). If you have multiple versions of unity installed on your machine, we recommend that you install [Unity Hub](https://unity3d.com/get-unity/download) as well to manage the versions you use.
 <!-- **Note**: If you are using Mac OS Catalina or later (>10.15.x), you should install this version of Unity with the "Unity Editor" not the "Unity Installer" due to the differences in how storage is managed in newer versions of Mac OS. -->

### Getting set up

First, open up the current folder in Unity 2018.4.36f1 either directly from the Unity Editor or through Unity Hub. Next, inside of the `Assets` folder you will find all of the Scenes used in the project. The scene used in the Unity Build is `FinalScene`. 

The scripts can be found in `Assets/Scripts` where `ConfigReader.cs` in `Assets/Scripts/Logic` handles parsing of the configuration file. The scripts themselves are documented and you can modify them as needed. 

### Configuration File Overview
The configuration file is automatically produced by the MATLAB header script and is read by the Unity build to inform the order of trial presentation along with other important characteristics. You can find a review of each line and its purpose below, but the repository also contains a `general.txt` which offers a similar explanation. 

>**Note**: Lines CANNOT have extra whitespace before or after them, so don't put any spaces after a line!

**config.txt**

| Line | Example Value | Type | Description 
|---|---|---|---|
| 1  | 999  | int  | Participant Number  |
| 2  | DS997  | string  | Location identifier and participant number. To change the location identifier you must change the `SITE` variable in `header_header.m` |
| 3  | 10.0  | float  | Collision sphere's radius (meters)|
| 4  | 10.0  | float  | Player's movement speed (virtual meters per second)  |
| 5  | 0  | int  | Defines the Mode. Sets the phase to Learning if it is 0. Sets the phase to Free Roam if it is 1. Sets the phase to Testing if it is 2. | 
| 6  | 60.0  |  float | Phase's time limit (seconds)  |
| 7  | 1.0  | float  | Time in seconds that the initial image is shown |
| 8  | 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 | int | Parsed by 4s. Position 1-4 corresponds to the snow environment; 5-8 to desert; 9-12 to arena; 13-16 to forest; 17-20 to castle; 21-24 to factory; 25-28 to volano. First four and final 8 are static and 5-20 are randomized across participants.  |
| 9  | 4 0 0 0 2 3 4 5 6 0 | int | The order of environments that the participant moves through |
| 10  | 1 1 2 3 0 0 0 0 0 0 | int | Spawn locations corresponding to cardinal values. 0 is North; 1 is East; 2 is South; 3 is West |
| 11  | 1 2 1 3 0 0 0 0 0 0 | int | Object spawn corners. 1 is North West; 2 is North East; 3 is South East; 4 is South West. If the trial is Free Roam, put 0 so that no object is shown. |

>**Note**: The directions on lines 10 and 11 are not relative to the task itself, but merely for clarification in labelling. Here, we'll specify the landmark along the side of the environment which was labelled as 'North'. 

| Northern Landmark | Environment |
|---|---|
| 0 | Snow |
| Rocks | Desert |
| 2 | Arena |
| Flowers | Meadow |
| Trees | Castle |
| 5 | Factory |
| 6 | Volcano |

### Environment Numbers: 

As noted on the `config.txt` Line 9, environments are assigned an integer. The assignment is broken down below.

| Number | Environment |
|---|---|
| 0 | Snow |
| 1 | Desert |
| 2 | Arena |
| 3 | Meadow |
| 4 | Castle |
| 5 | Factory |
| 6 | Volcano |

Each of these environments, unlike volt, has a set of red pillars - one in each corner. Though these pillars were note used in the experiment's final build, they remain as a tool that can be included to help participants learn where they might find objects.

> **Note**: Free roam always occurred within the practice environment (env 6) but others can be used. Free roam also used 1000 seconds for time instead of 60. Please also note that, in lines 9-11 for free roam, there have to be a minimum of 2 columns.
Also, in Sherrill et al., Desert, Arena, Meadow, and Castle were used in the task while Volcano was used for free roam and practice. 

### Building

After you've completed the modification to the code and/or environments that you wanted, you can now open Build Settings in the Unity Editor by going to `File > Build Settings`. From the menu that opens, make sure that `FinalScene` or the Scene that you want in your build is selected. If nothing is selected in `Scenes in Build`, double click on the Scene you want in the Unity Editor and make sure that it is open in your `Hierarchy`. Now click back to the `Build Settings` window and click `Add Open Scenes`. From here, ensure that you have selected your preferred target platform and hit `Build`. You will be prompted to choose a directory at which point you can choose the current directory. You can either replace the `Build.app` in the current directory with your new `Build.app` or archive the old one. 

> **Note**: Naming your new build `Build.app` is important as the `voltage.sh` script uses this name to run the experiment. You are welcome to change the script if you prefer to use a different name. 

From here you should be all set to run your new experiment! From here, revisit the [Running the Experiment](#running-the-experiment) instructions above, if applicable.  


## Authors
Roles and affiliations of authors at the time of data collection.
  - **Katherine R. Sherrill<sup>1,4</sup>** - *Post Doctoral Research Fellow* - [GitHub](https://github.com/orgs/prestonlab/people/ksherrill)
  - **Neal Morton<sup>1</sup>** - *Post Doctoral Research Fellow* - [Google Scholar](https://scholar.google.com/citations?hl=en&user=MtKrq88AAAAJ)
  - **Andrew Watrous<sup>3</sup>** - *Assistant Professor at the Dell Seton Medical Center at UT Austin* - [Google Scholar](https://scholar.google.com/citations?user=bN_WKCIAAAAJ&hl=en)
  - **Alison R. Preston<sup>1,2,4</sup>** - *Principle Investigator* - [Preston Lab](https://clm.utexas.edu/preston/)

1. Center for Learning and Memory, University of Texas at Austin, Austin, TX 78712, USA
2. Department of Psychology, University of Texas at Austin, Austin, TX 78712, USA
3. Department of Medicine, University of Texas at Austin, Austin, TX 78712, USA
4. Department of Neuroscience, University of Texas at Austin, Austin, TX 78712, USA

## Notes and Funding

This research was supported by the National Institute of Mental Health (R01 MH100121-01 to A.R.P.) and the National Institute of Neurological Disorders and Stroke (National Research Service Award F32 NS098808 to K.R.S.) of the National Institutes of Health. [R21 Grant] [Neal's Grant from Eye Institute]

This software is not sponsored by or affiliated with Unity Technologies or its affiliates. Unity Trademarks are trademarks or registered trademarks of Unity Technologies or its affiliates in the U.S. and elsewhere.

## Acknowledgments

Thanks to Hannah Roome, Athula Pudhiyidath, Christine Coughlin, and Nicole Varga for valuable discussions.
