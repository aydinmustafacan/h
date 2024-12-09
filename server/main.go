package main

import (
	"context"
	"fmt"
	"log"
	"net"

	"server/proto"

	"google.golang.org/grpc"
)

type server struct {
	proto.UnimplementedGreeterServer
}

func (s *server) SayHello(ctx context.Context, in *proto.HelloRequest) (*proto.HelloReply, error) {
	log.Println("Request received!")

	message := fmt.Sprintf("Hey, my dear friend %s", in.Name)

	return &proto.HelloReply{Message: message}, nil
}

func main() {
	lis, err := net.Listen("tcp", ":50000")
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	sopts := []grpc.ServerOption{}

	s := grpc.NewServer(sopts...)
	proto.RegisterGreeterServer(s, &server{})

	log.Printf("Starting server...")
	if err := s.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}
