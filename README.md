<div id="top"></div>
<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/github_username/repo_name">
    <img src="images/terralogo.png" alt="Logo" width="80" height="80">
  </a>

<h3 align="center">Swiftie Terraform and AWS automated resource provisioning</h3>

  <p align="center">
    Singapore Management University (IS458 Cloud Management and Engineering
G2T2) Swiftie Online Digital Bank Cloud Computing Provisioning
    <br />
    <a href="https://github.com/Vasn/swiftie-terraform"><strong>Explore the docs »</strong></a>
  </p>
</div>



<!-- ABOUT THE PROJECT -->
## About The Project

This is a project for Swiftie Bank Cloud Management and Engineering Module in Singapore Management University. It contains the core AWS resources required for our infrastructure using terraform to automate the provisioning of our cloud infrastructure, network and resources. The resources includes:
* Networking infrastructure like VPCs, public and private subnets, internet gateway, NAT, elastic IPs, route tables, routes, route table associations, network interfaces, DNS, DNS records
* Security groups for network interfaces and VPC
* Other resources like EC2 Instances and application load balancers


<p align="right">(<a href="#top">back to top</a>)</p>



### Built With

* [Terraform](https://www.terraform.io/)

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- GETTING STARTED -->
## Getting Started
This is the instructions on how to get yourself set up with this terraform application.
To get a local copy up and running follow these simple example steps.

### Installation

1. Download a copy or clone the repo
   ```sh
   git clone https://github.com/Vasn/swiftie-terraform.git
   ```
   
2. Install Terraform executables and set PATH environment from https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
3. Configure the following file at the following path (~/.aws/credentials) with your AWS credentials (profile name, access key and secret key). For example:
<br />
[myprofilenamehere] <br />
aws_access_key_id = xxxxxxxxxxxx123 <br />
aws_secret_access_key = yyyyyyyyyyyy321 <br />


<p align="right">(<a href="#top">back to top</a>)</p>


<!-- CONTACT -->
## Contact

Project Link: [https://github.com/Vasn/swiftie-terraform](https://github.com/Vasn/swiftie-terraform)

* Vasilis - vasilis.ng.2020@scis.smu.edu.sg
* Yuki - yuki.han.2020@scis.smu.edu.sg
* Shya - swquah.2020@scis.smu.edu.sg
* Jacky- jacky.teo.2020@scis.smu.edu.sg
* Erlynne - erlynneong.2020@scis.smu.edu.sg

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/github_username/repo_name.svg?style=for-the-badge
[contributors-url]: https://github.com/github_username/repo_name/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/github_username/repo_name.svg?style=for-the-badge
[forks-url]: https://github.com/github_username/repo_name/network/members
[stars-shield]: https://img.shields.io/github/stars/github_username/repo_name.svg?style=for-the-badge
[stars-url]: https://github.com/github_username/repo_name/stargazers
[issues-shield]: https://img.shields.io/github/issues/github_username/repo_name.svg?style=for-the-badge
[issues-url]: https://github.com/github_username/repo_name/issues
[license-shield]: https://img.shields.io/github/license/github_username/repo_name.svg?style=for-the-badge
[license-url]: https://github.com/github_username/repo_name/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/linkedin_username
[product-screenshot]: images/screenshot.png
