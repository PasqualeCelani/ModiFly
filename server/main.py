import socket
import json
import cv2
import mediapipe as mp
import time
import speech_recognition as sr
import threading
import queue

UDP_IP = "127.0.0.1"  
UDP_PORT = 5005 

CALLBACK_GESTURE = "None"
voice_command_queue = queue.Queue() 

def is_thumb_left(hand_landmarks):
    lm = hand_landmarks.landmark

    thumb_extended = lm[4].x < lm[3].x < lm[2].x

    knuckles = [5, 9, 13, 17]

    for knuckle in knuckles:
        if not (lm[knuckle+3].y > lm[knuckle].y):
            return False
        
    return thumb_extended 

def is_thumb_right(hand_landmarks):
    lm = hand_landmarks.landmark

    thumb_extended = lm[4].x > lm[3].x > lm[2].x

    knuckles = [5, 9, 13, 17]

    for knuckle in knuckles:
        if not (lm[knuckle+3].y > lm[knuckle].y):
            return False
        
    return thumb_extended 


def send_udp_message(sock, command):
    gesture = {"command": command}
    message = json.dumps(gesture).encode('utf-8')
    sock.sendto(message, (UDP_IP, UDP_PORT))

def result_callback(result, output_image, timestamp_ms):
    global CALLBACK_GESTURE
    CALLBACK_GESTURE = "None"
    if result.handedness:
        hand_label = result.handedness[0][0].category_name 
        if hand_label == "Right":
            if result.gestures:
                gesture = result.gestures[0][0].category_name
                CALLBACK_GESTURE = gesture
        else:
            if result.gestures:
                gesture = result.gestures[0][0].category_name
                if gesture == "Open_Palm":
                    CALLBACK_GESTURE = "Open_Palm_Right"


def callback(recognizer, audio):
    global VOICE_COMMAND
    try:
        text = recognizer.recognize_google(audio).lower()
        print(f"Recognized: {text}")
        if text in ["open", "shut down", "zoom in", "zoom out", "stop"]:
            voice_command_queue.put(text)
    except sr.UnknownValueError:
        print("Could not understand audio")
    except sr.RequestError as e:
        print(f"API Error: {e}")



def listen_continuously():
    r = sr.Recognizer()
    mic_index = 0

    print("Adjusting for ambient noise...")
    with sr.Microphone(device_index=mic_index) as source:
        r.adjust_for_ambient_noise(source)
    print("Ready for commands.")

    r.listen_in_background(sr.Microphone(device_index=mic_index), callback)

    while True:
        print(f"Current command: {VOICE_COMMAND}")
        time.sleep(1)


def main():
    global CALLBACK_GESTURE
    global VOICE_COMMAND

    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    cap = cv2.VideoCapture(0)

    mp_hands = mp.solutions.hands
    mp_drawing = mp.solutions.drawing_utils

    BaseOptions = mp.tasks.BaseOptions
    GestureRecognizer = mp.tasks.vision.GestureRecognizer
    GestureRecognizerOptions = mp.tasks.vision.GestureRecognizerOptions
    VisionRunningMode = mp.tasks.vision.RunningMode

    hands = mp_hands.Hands(
        static_image_mode=False,
        max_num_hands=2,
        min_detection_confidence=0.5,
        min_tracking_confidence=0.5 
    )

    options = GestureRecognizerOptions(
        base_options=BaseOptions(model_asset_path='./resources/gesture_recognizer.task'),
        running_mode=VisionRunningMode.LIVE_STREAM,
        min_hand_detection_confidence=0.5,
        min_tracking_confidence=0.5,
        result_callback=result_callback
    )

    recognizer = GestureRecognizer.create_from_options(options)
    prev_timestamp_ms = 0

    voice_thread = threading.Thread(target=listen_continuously, daemon=True)
    voice_thread.start()    

    while cap.isOpened():
        success, image = cap.read()
        if not success:
            break
        
        image = cv2.flip(image, 1)
        image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)

        results = hands.process(image_rgb)
        
        current_timestamp_ms = int(time.time() * 1000)
        if current_timestamp_ms > prev_timestamp_ms:
            mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=image_rgb)
            recognizer.recognize_async(mp_image, current_timestamp_ms)
        
        isClassifierGestureRec = False
        
        gesture_by_hand = {
            "left": "None",
            "right": "None"
        }

        if CALLBACK_GESTURE in ["Open_Palm", "Closed_Fist", "Thumb_Up", "Thumb_Down"]:
            isClassifierGestureRec = True
            if CALLBACK_GESTURE == "Open_Palm":
                print("Open_Palm")
                gesture_by_hand["left"] = "forward"
            elif CALLBACK_GESTURE == "Closed_Fist":
                print("Closed_Fist")
                gesture_by_hand["left"] = "backward"
            elif CALLBACK_GESTURE == "Thumb_Up":
                print("Thumb_Up")
                gesture_by_hand["left"] = "up"
            elif CALLBACK_GESTURE == "Thumb_Down":
                print("Thumb_Down")
                gesture_by_hand["left"] = "down"

        if results.multi_hand_landmarks:
            for hand_landmarks, hand_handedness in zip(results.multi_hand_landmarks, results.multi_handedness):
                #----- For DEBUG ---- 
                #mp_drawing.draw_landmarks(image, hand_landmarks, mp_hands.HAND_CONNECTIONS)
                #----- For DEBUG ---- 
                hand_label = hand_handedness.classification[0].label
                if hand_label == "Left" and (not isClassifierGestureRec):
                    if is_thumb_right(hand_landmarks):
                        print("right")
                        gesture_by_hand["left"] = "right"
                    elif is_thumb_left(hand_landmarks):
                        print("left")
                        gesture_by_hand["left"] = "left"
                
                if hand_label == "Right":
                    if is_thumb_right(hand_landmarks):
                        print("rotate_right")
                        gesture_by_hand["right"] = "rotate_right"
                    elif is_thumb_left(hand_landmarks):
                        print("rotate_left")
                        gesture_by_hand["right"] = "rotate_left"

        voice_command = "None"
        try:
            voice_command = voice_command_queue.get_nowait()
        except queue.Empty:
            pass

        data_to_send = {
            "gestures_commands": gesture_by_hand,
            "voice_commands": voice_command
        }

        CALLBACK_GESTURE  = "None"
        VOICE_COMMAND = "None"
        send_udp_message(sock, data_to_send)

        #----- For DEBUG ---- 
        #cv2.namedWindow('Modifly', cv2.WINDOW_NORMAL)
        #cv2.imshow("Modifly", image)
        #----- For DEBUG ----             

        if cv2.waitKey(1) & 0xFF == 27:  # ESC key
            break

    cap.release()
    cv2.destroyAllWindows()
    sock.close()


if __name__ == "__main__":
    main()
