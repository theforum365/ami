# theforum365 AMI

This repo contains the AMI that is used for the www.theforum365.com. It builds a [AWS Graviton](https://aws.amazon.com/ec2/graviton/) AMI.

It is built using [Packer](https://www.packer.io/)

The operating system dependencies are managed via shell scripts and [Puppet](https://puppet.com/).

## Dependencies

To build the AMI manually, you need to have a few dependencies installed:

- [jkcfg](https://github.com/jkcfg/jk) is a configuration as code tool which is used to define the packer manifest. It builds a `packer.json` file which is passed to Packer
- [Packer](https://www.packer.io/) also needs to be installed

## Building the AMI

Once you have the dependencies installed, you'll also need to have some AWS credentials for our AWS account.

Once that's done, you can simply run:

```
make build
```

Which will take care of building the `packer.json` file using `jkcfg` and then running packer against the built manifest.

### Debug builds

You can build the AMI with debugging enabled, which will stop at each step in the packer process for you to verify what's happening. Simple run:

```
make debug
```

You'll get an interact prompt during the build process.


## Nightly Builds

In order to ensure the AMI has the latest security updates, we build the AMI nightly using GitHub Actions. This will install the latest security updates. This will take care of building the AMI and propagating it to our AWS account.
