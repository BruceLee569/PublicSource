#!/bin/bash

# 定义目录变量
model_dir=/root/autodl-tmp/models
funasr_dir=/root/autodl-tmp/FunASR
llama_cpp_dir=/root/autodl-tmp/llama.cpp
cosyvoice_dir=/root/autodl-tmp/CosyVoice
musechat_dir=/root/autodl-tmp/MuseChat

# 日志和PID文件路径
log_dir=/root/autodl-tmp/logs
mkdir -p "$log_dir" || { echo "Failed to create log directory: $log_dir"; exit 1; }


# 获取CPU核心数
get_cpu_core_count() {
    local core_count
    core_count=$(cat /proc/cpuinfo | grep "processor" | wc -l)
    if [[ $? -ne 0 || -z "$core_count" ]]; then
        echo "Failed to get CPU core count. Defaulting to 32."
        core_count=32
    fi
    echo "$core_count"
}

# 启动ASR服务
start_asr_service() {
    cd "${funasr_dir}/runtime/websocket" || { echo "Failed to enter ASR directory"; return 1; }
    cmd_path="${funasr_dir}/runtime/websocket/build/bin"
    port=10096

    decoder_thread_num=$(get_cpu_core_count)
    multiple_io=16
    io_thread_num=$(( (decoder_thread_num + multiple_io - 1) / multiple_io ))
    model_thread_num=1

    echo "Starting ASR service on port: $port"

    nohup "$cmd_path/funasr-wss-server-2pass" \
        --download-model-dir "${model_dir}" \
        --model-dir "damo/speech_paraformer-large-vad-punc_asr_nat-zh-cn-16k-common-vocab8404-onnx" \
        --online-model-dir "damo/speech_paraformer-large_asr_nat-zh-cn-16k-common-vocab8404-online-onnx" \
        --vad-dir "damo/speech_fsmn_vad_zh-cn-16k-common-onnx" \
        --punc-dir "damo/punc_ct-transformer_zh-cn-common-vad_realtime-vocab272727-onnx" \
        --itn-dir "thuduj12/fst_itn_zh" \
        --lm-dir "damo/speech_ngram_lm_zh-cn-ai-wesp-fst" \
        --decoder-thread-num "$decoder_thread_num" \
        --model-thread-num "$model_thread_num" \
        --io-thread-num "$io_thread_num" \
        --port "$port" \
        --certfile "" \
        --keyfile "" \
        --hotword "亦菲 50" > "${log_dir}/asr.log" 2>&1 &

    echo $! > "${log_dir}/asr.pid"
    echo "ASR service started. PID: $(cat "${log_dir}/asr.pid")"
}

# 启动LLM服务
start_llm_service() {
    cd "$llama_cpp_dir" || { echo "Failed to enter LLM directory"; return 1; }

    echo "Starting LLM service on port 8080"

    nohup ./build/bin/llama-server \
        -m "/root/autodl-tmp/models/Qwen2-7B/Qwen2-7B-Multilingual-RP.Q6_K.gguf" \
        -ngl 100 \
        --host 0.0.0.0 \
        --port 8080 > "${log_dir}/llm.log" 2>&1 &

    echo $! > "${log_dir}/llm.pid"
    echo "LLM service started. PID: $(cat "${log_dir}/llm.pid")"
}

# 启动TTS服务
start_tts_service() {
    cd "$cosyvoice_dir" || { echo "Failed to enter TTS directory"; return 1; }

    # 激活Conda环境
    conda init
    if ! conda activate cosyvoice; then
        echo "Failed to activate Conda environment 'cosyvoice'"
        return 1
    fi

    echo "Starting TTS service"

    nohup python server.py > "${log_dir}/tts.log" 2>&1 &

    echo $! > "${log_dir}/tts.pid"
    echo "TTS service started. PID: $(cat "${log_dir}/tts.pid")"
}

# 启动 MuseChat，统一8000端口对外提供服务
start_muse_chat_service() {
    cd "$musechat_dir" || { echo "Failed to enter MuseChat directory"; return 1; }

    # 激活Conda环境
    conda init
    if ! conda activate musechat; then
        echo "Failed to activate Conda environment 'musechat'"
        return 1
    fi

    echo "Starting MuseChat service"

    nohup python main.py > "${log_dir}/musechat.log" 2>&1 &

    echo $! > "${log_dir}/musechat.pid"
    echo "MuseChat service started. PID: $(cat "${log_dir}/musechat.pid")"
}

# 主函数
main() {
    echo "Starting services..."

    start_asr_service
    start_llm_service
    start_tts_service
    start_muse_chat_service
    
    echo "All services started. Logs are saved in: $log_dir"
}

# 执行主函数
main
