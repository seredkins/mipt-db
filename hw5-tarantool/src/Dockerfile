FROM tarantool/tarantool:latest

RUN apt-get update && apt-get install -y unzip
RUN apt-get update && apt-get install -y git

RUN apt-get update && apt-get -y install cmake protobuf-compiler
RUN tt rocks install expirationd

ENV TT_APP_NAME=app
CMD ["tarantool"]
