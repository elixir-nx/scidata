# Scidata

## Usage

We currently support MNIST, FashionMNIST, and CIFAR10 training and test datasets.

Download or fetch datasets locally:

```elixir
{train_images, train_labels} = Scidata.MNIST.download()
{test_images, test_labels} = Scidata.MNIST.download(test_set: true)

# Unpack train_images like...
{images_binary, tensor_type, shape} = train_images
```

You can also pass transform functions to `download/1`:

```elixir
transform_images = fn {binary, type, shape} ->
  binary
  |> Nx.from_binary(type)
  |> Nx.reshape(shape)
  |> Nx.divide(255)
  |> Nx.to_batched_list(32)
end

{train_images, train_labels} =
  Scidata.MNIST.download(transform_images: transform_images)

# Transform labels as well, e.g. get one-hot encoding
transform_labels = fn {labels_binary, type, _} ->
  labels_binary
  |> Nx.from_binary(type)
  |> Nx.new_axis(-1)
  |> Nx.equal(Nx.tensor(Enum.to_list(0..9)))
  |> Nx.to_batched_list(32)
end

{images, labels} =
  Scidata.MNIST.download(
    transform_images: transform_images,
    transform_labels: transform_labels
  )

```

## Installation

```elixir
def deps do
  [
    {:scidata, "~> 0.1.0-dev", github: "elixir-nx/scidata"}
  ]
end
```

## License

Copyright (c) 2021 Tom Rutten

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
