#!/bin/bash

# ASR
model_dir=/root/autodl-tmp/models
funasr_dir=/root/autodl-tmp/FunASR
cd ${funasr_dir}/runtime/websocket
cmd_path=${funasr_dir}/runtime/websocket/build/bin
port=10096

decoder_thread_num=$(cat /proc/cpuinfo | grep "processor"|wc -l) || { echo "Get cpuinfo failed. Set decoder_thread_num = 32"; decoder_thread_num=32; }
multiple_io=16
io_thread_num=$(( (decoder_thread_num + multiple_io - 1) / multiple_io ))
model_thread_num=1

$cmd_path/funasr-wss-server-2pass  \
  --download-model-dir "${model_dir}" \
  --model-dir "damo/speech_paraformer-large-vad-punc_asr_nat-zh-cn-16k-common-vocab8404-onnx" \
  --online-model-dir "damo/speech_paraformer-large_asr_nat-zh-cn-16k-common-vocab8404-online-onnx" \
  --vad-dir "damo/speech_fsmn_vad_zh-cn-16k-common-onnx" \
  --punc-dir "damo/punc_ct-transformer_zh-cn-common-vad_realtime-vocab272727-onnx" \
  --itn-dir "thuduj12/fst_itn_zh" \
  --lm-dir "damo/speech_ngram_lm_zh-cn-ai-wesp-fst" \
  --decoder-thread-num ${decoder_thread_num} \
  --model-thread-num ${model_thread_num} \
  --io-thread-num  ${io_thread_num} \
  --port ${port} \
  --certfile  "" \
  --keyfile "" \
  --hotword ""
  
# nohup $cmd_path/funasr-wss-server-2pass  \
#   --download-model-dir "${model_dir}" \
#   --model-dir "damo/speech_paraformer-large-vad-punc_asr_nat-zh-cn-16k-common-vocab8404-onnx" \
#   --online-model-dir "damo/speech_paraformer-large_asr_nat-zh-cn-16k-common-vocab8404-online-onnx" \
#   --vad-dir "damo/speech_fsmn_vad_zh-cn-16k-common-onnx" \
#   --punc-dir "damo/punc_ct-transformer_zh-cn-common-vad_realtime-vocab272727-onnx" \
#   --itn-dir "thuduj12/fst_itn_zh" \
#   --lm-dir "damo/speech_ngram_lm_zh-cn-ai-wesp-fst" \
#   --decoder-thread-num ${decoder_thread_num} \
#   --model-thread-num ${model_thread_num} \
#   --io-thread-num  ${io_thread_num} \
#   --port ${port} \
#   --certfile  "" \
#   --keyfile "" \
#   --hotword "" > output.log 2>&1 & echo $! > pid.txt
#tail -f output.log

# LLM
cd /root/autodl-tmp/llama.cpp/build
./bin/llama-server -m /root/autodl-tmp/models/llm/Peach-9B-8k-Roleplay.Q8_0.gguf -ngl 100 --host 0.0.0.0 --port 8080
#nohup ./bin/llama-server -m /root/autodl-tmp/models/Qwen2-7B/Qwen2-7B-Multilingual-RP.Q6_K.gguf -ngl 100 --host 0.0.0.0 --port 8080  > output.log 2>&1 & echo $! > pid.txt
#tail -f output.log

# TTS
cd /root/autodl-tmp/CosyVoice
conda activate cosyvoice
python server.py
#nohup python server.py  > output.log 2>&1 & echo $! > pid.txt
#tail -f output.log

# T2I
cd /root/autodl-tmp/flux-fp8-api
conda activate flux-fp8-matmul-api
python main.py --config-path "./configs/myconfig_schnell_4090.json" --host "0.0.0.0" --port 8088
#nohup python main.py --config-path "./configs/myconfig_schnell_4090.json" --host "0.0.0.0" --port 8088 > output.log 2>&1 & echo $! > pid.txt
#tail -f output.log

