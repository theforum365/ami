import * as param from '@jkcfg/std/param';

const packerConfig = {
    min_packer_version: "1.5.6",
    variables: {
        subnet_id: "",
        associate_public_ip_address: "true",
        ami_filter_name: "",
        ebs_volume_size: "8",
    },
    builders: [{
        name: "forum-arm64",
        ami_name: "forum-arm64-{{isotime | clean_resource_name}}-arm64",
        ami_description: "Amazon Linux Instance with Forum Software Installed",
        instance_type: "t4g.micro",
        ami_users: "791046510159",
        region: "eu-west-1",
        type: "amazon-ebs",
        subnet_id: "{{user `subnet_id`}}",
        associate_public_ip_address: "{{user `associate_public_ip_address`}}",
        availability_zone: "eu-west-1a",
        source_ami_filter: {
            "filters": {
                "name": "amzn2-ami-hvm-*-arm64-gp2",
                "root-device-type": "ebs",
                "virtualization-type": "hvm"
            },
            "most_recent": true,
            "owners": [
                "137112412989"
            ]
        },
        ami_block_device_mappings: [
            {
                "device_name": "/dev/sda1",
                "volume_size": "{{user `ebs_volume_size` }}",
                "volume_type": "gp2",
                "delete_on_termination": true
            }
        ],
        ssh_username: "ec2-user",
        tags: {
            Name: "theforum365-arm64-{{isotime | clean_resource_name}}",
            OS_Version: 'amzn-2-arm64',
            Created_Using: 'packer',
            Build_ID: '{{user `build_id` }}',
            Created_On: '{{isotime|clean_resource_name}}',
            Timestamp: '{{timestamp}}',
            "Amazon_AMI_Management_Identifier": "theforum365-arm64",
        }

    }],
    provisioners: [{
        type: "shell",
        scripts: [
          "scripts/bootstrap.sh",
          "scripts/install_puppet.sh"
        ],
    }, {
        type: "puppet-masterless",
        manifest_file: "./puppet/manifests/site.pp",
        module_paths: "./puppet/modules",
        puppet_bin_dir: "/opt/puppetlabs/bin",
    }],
    'post-processors': [
        {
            "identifier": "theforum365-arm64",
            "keep_releases": "3",
            "type": "amazon-ami-management",
            regions: ["eu-west-1"]
        }, {
            "custom_data": {
                "identifier": "theforum365-arm64",
            },
            "type": "manifest"
        }
    ],

}

export default [
    {value: packerConfig, file: `packer.json`},
]

