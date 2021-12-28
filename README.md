# Scidata

## Usage

Scidata currently supports the following training and test datasets:

- CIFAR10
- CIFAR100
- FashionMNIST
- IMDb Reviews
- Kuzushiji-MNIST (KMNIST)
- MNIST
- SQuAD
- Yelp Reviews (Full and Polarity)

Download or fetch datasets locally:

```elixir
{train_images, train_labels} = Scidata.MNIST.download()
{test_images, test_labels} = Scidata.MNIST.download_test()

# Unpack train_images like...
{images_binary, tensor_type, shape} = train_images
```

Most often you will convert those results to `Nx` tensors:

```elixir
{train_images, train_labels} = Scidata.MNIST.download()

# Normalize and batch images
{images_binary, images_type, images_shape} = train_images

batched_images =
  images_binary
  |> Nx.from_binary(images_type)
  |> Nx.reshape(images_shape)
  |> Nx.divide(255)
  |> Nx.to_batched_list(32)

# One-hot-encode and batch labels
{labels_binary, labels_type, _shape} = train_labels

batchd_labels =
  labels_binary
  |> Nx.from_binary(labels_type)
  |> Nx.new_axis(-1)
  |> Nx.equal(Nx.tensor(Enum.to_list(0..9)))
  |> Nx.to_batched_list(32)
```

## Installation

```elixir
def deps do
  [
    {:scidata, "~> 0.1.3"}
  ]
end
```

## Contributing

PRs are encouraged! Consider using [utils](https://github.com/elixir-nx/scidata/blob/master/lib/scidata/utils.ex) to add your favorite dataset or one from [this list](https://github.com/elixir-nx/scidata/issues/16).

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
