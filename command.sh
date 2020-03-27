#!/usr/bin/env bash

protoc model/*.proto \
    --proto_path=model \
    --plugin=protoc-gen-swift \
    --swift_opt=Visibility=Public \
    --swift_out=model \
    --plugin=protoc-gen-grpc-swift \
    --grpc-swift_opt=Visibility=Public \
    --grpc-swift_out=model