#include <grpcpp/grpcpp.h>

#include <iostream>

#include "example.grpc.pb.h"

class Client
{
  public:
    explicit Client(const std::shared_ptr<grpc::Channel>& channel) : stub_(example::Greeter::NewStub(channel)){};

    std::string SayHello(std::string name) const
    {
        // Fill out the request which with the name
        example::HelloRequest request{};
        request.set_name(name);

        // Data placeholder for the response
        example::HelloReply response{};

        // Allows us to store additional data from the client, but for this example we leave it empty
        grpc::ClientContext context{};

        const auto status = stub_->SayHello(&context, request, &response);

        std::string response_message{};
        if (status.ok())
        {
            response_message = response.message();
        }
        else
        {
            // We can be more fancy here and add more verbose messages as a response, but let's keep it simple
            response_message = "Error! RPC failed";
        }

        return response_message;
    }

  private:
    std::unique_ptr<example::Greeter::Stub> stub_;
};

int main()
{
    std::cout << "Starting client...\n";

    const auto client = Client(grpc::CreateChannel("localhost:50000", grpc::InsecureChannelCredentials()));
    const auto response = client.SayHello("Zvonimir");

    std::cout << "Received following message: " << response;

    return EXIT_SUCCESS;
}