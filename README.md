flowchart LR
  U[Usuario / Dev] --> GH[GitHub Repository]
  U --> TFCLI[Terraform CLI Local]

  GH --> GHA[GitHub Actions CI/CD]
  GHA --> OIDC[s22]
  GHA --> TF[Terraform Runtime]

  TFCLI --> TF
  TF --> STATE[(Terraform State<br/>Azure Storage)]

  subgraph CODE[Codigo IaC]
    M1[s23]
    M2[s24]
    M3[s25]
  end

  TF --> M1
  TF --> M2
  TF --> M3

  subgraph AZ[Azure - lab8-rg]
    VNET[s26]
    NSG[s27]
    LB[s28]
    VM0[VM lab8-vm-0]
    VM1[VM lab8-vm-1]
    BAS[Bastion Host]
    MON[Monitor Alert + Action Group]
    BUD[Monthly Budget Alert]
  end

  M1 --> VNET
  M1 --> NSG
  M2 --> VM0
  M2 --> VM1
  M2 --> BAS
  M3 --> LB

  LB --> VM0
  LB --> VM1

  TF --> MON
  TF --> BUD
  MON -.->|s29| U