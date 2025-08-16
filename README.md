# ModiFly
ModiFly is a simulator designed to test a new Human-Drone Interaction (HDI) model that moves beyond traditional, joystick-based interfaces. The project leverages natural human communication modalities, specifically gestures and speech, to create a more intuitive and seamless control experience. The system is designed to be low-cost, easy to use, and capable of running on low-end hardware.

<br>

## :movie_camera: :arrow_forward: Showcase 
[![Watch the video](http://img.youtube.com/vi/hgjOizbrNE0/maxresdefault.jpg)](http://www.youtube.com/watch?v=hgjOizbrNE0)

##  :rocket: Key Features
* :large_blue_diamond: **Multimodal interaction:**  integrates two primary modalities such as gestures for continuous drone movement and voice commands for discrete, supportive functions;
* :open_hands: **Two handed gesture control:** A two-handed gesture system is used for handling drone movement, with the left hand controlling position (lateral, altitude, forward/backward) and the right hand controlling rotational yaw;
* :microphone: **Intuitive voice commands:** A set of simple voice commands such as "open", "shut down", "zoom in", "zoom out" and "stop" are used to control system states and camera functions;
* :computer: **Low computational requirements:** The system is designed to be efficient, successfully running on a 2019 MacBook Air with a dual-core i5 processor and 8GB of RAM;
* :seedling: **Natural interaction** The multimodal framework allows for simultaneous, parallel task execution, for example controlling movement with gestures while issuing a voice command, which reduces cognitive load and enhances operational efficiency.

## :dvd: Install

### :warning: Warning
The ModiFly simulator is currently only available on macOS systems with an Intel processor, as it has been specifically built for this environment. However, the Godot project files are included in the repository, allowing it to be loaded and built for any other operating system and device supported by Godot.

### :hammer: Prerequisites
 Python is required to run the backend server for gesture and voice recognition. The project was developed using Python 3.12, but newer versions should also work.

### :arrow_forward: Execution steps (OSX)
 1. Download the latest release of the ModiFly application from this GitHub repository;
 2. Open the downloaded `.dmg` file and drag the ModiFly application to your `/Applications` folder;
 3. Inside the repository, locate and run the `run.sh` script. This will launch the necessary backend server and the ModiFly application.

## :books: Documentation
All the required documentation can be found in `/doc/main.pdf` contained in this repository. This documentation is useful for gaining a better understanding of the project's idea, goals, and scope.

## :paperclip: License 
This project is released under the MIT License.
