'''
This is an example on how to use the API for oobabooga/text-generation-webui.
Make sure to start the web UI with the following flags:
python server.py --model MODEL --listen --no-stream
Optionally, you can also add the --share flag to generate a public gradio URL,
allowing you to use the API remotely.
'''
import requests

# Server address
HOST = 'localhost:5000'
URI = f'http://{HOST}/api/v1/generate'

# Generation parameters
# Reference: https://huggingface.co/docs/transformers/main_classes/text_generation#transformers.GenerationConfig
def run(prompt):
    request = {
        'prompt': prompt,
        'max_new_tokens': 50,
        'do_sample': True,
        'temperature': 0.9,
        'top_p': 1.0,
        'typical_p': 1,
        'epsilon_cutoff': 0,  # In units of 1e-4
        'eta_cutoff': 0,  # In units of 1e-4
        'tfs': 1,
        'top_a': 0,
        'repetition_penalty': 1.18,
        'top_k': 40,
        'min_length': 0,
        'no_repeat_ngram_size': 0,
        'num_beams': 1,
        'penalty_alpha': 0,
        'length_penalty': 1,
        'early_stopping': False,
        'mirostat_mode': 0,
        'mirostat_tau': 5,
        'mirostat_eta': 0.1,
        'seed': -1,
        'add_bos_token': True,
        'truncation_length': 2048,
        'ban_eos_token': False,
        'skip_special_tokens': True,
        'stopping_strings': ["\nYou:"]
    }

    response = requests.post(URI, json=request)

    if response.status_code == 200:
        result = response.json()['results'][0]['text']
        return result



response = None

# Input prompt
temp_prompt = ""
current_prompt = ""
response = ""
await_response = False
character_def_file = open("D:/[01] General Games/Sonic Robo Blast 2/luafiles/bluespring/AI-IO/AI_Character1.txt", "r")
character_def = character_def_file.read()
character_def_file.close()

input_prompt = open("D:/[01] General Games/Sonic Robo Blast 2/luafiles/bluespring/AI-IO/input_prompt.txt", "r")


while(True):
    if input_prompt:
        input_prompt.seek(0, 0)
        temp_prompt = input_prompt.read()
        if current_prompt != temp_prompt and temp_prompt != "" and not await_response:
            if __name__ == '__main__':
                response = run(character_def+" "+temp_prompt)

            await_response = True
            current_prompt = temp_prompt
            print(temp_prompt)

        if await_response and response:
            receive_prompt = open("D:/[01] General Games/Sonic Robo Blast 2/luafiles/bluespring/AI-IO/receive_prompt.txt", "w")
            actual_response = response.strip('You:')

            receive_prompt.write(actual_response)
            await_response = False

            receive_prompt.close()

            print("<BOT>:", actual_response)


    else:
        break

input_prompt.close()