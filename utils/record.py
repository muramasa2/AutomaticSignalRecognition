import keyboard  # using module keyboard
import pyaudio
import wave
import argparse
import os

parser = argparse.ArgumentParser(description='output audio name')
parser.add_argument('audio_name', help='output audio name')

args = parser.parse_args()

DEVICE_INDEX = 0
CHUNK = 1024
FORMAT = pyaudio.paInt16 # 16bit
CHANNELS = 1             # monaural
RATE = 16000             # sampling frequency [Hz]

output_path = f'./input_audio/{args.audio_name}.wav'

p = pyaudio.PyAudio()

stream = p.open(format=FORMAT,
                channels=CHANNELS,
                rate=RATE,
                input=True,
                input_device_index = DEVICE_INDEX,
                frames_per_buffer=CHUNK)


input("Press Space to Start and Stop recording!")
print("Start recording!")
print("Recording ...")

frames = []
while True:
    if keyboard.is_pressed('enter'):  # if key 'q' is pressed 
        print('Stop recording!')
        print("Save audio file")

        break  # finishing the loop

    else:
        data = stream.read(CHUNK, exception_on_overflow = False)
        frames.append(data)

stream.stop_stream()
stream.close()
p.terminate()

output = wave.open(output_path, 'wb')
output.setnchannels(CHANNELS)
output.setsampwidth(p.get_sample_size(FORMAT))
output.setframerate(RATE)
output.writeframes(b''.join(frames))
output.close()