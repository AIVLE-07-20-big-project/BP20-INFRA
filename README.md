# BP20-INFRA

매장 분석 및 온오프라인 운영 관리 AI 플랫폼 프론트엔드입니다. 점주는 매출·재고·리뷰 현황과 AI 기반 운영 전략을 확인할 수 있으며, 관리자는 입점 매장과 서비스 운영 현황을 관리할 수 있습니다.

## 실행 경로

```
배포주소 : https://dt555m45x3ua9.cloudfront.net
```

## 전체 기능

### 점주

- 매장 운영 대시보드
- 매출 및 비용 분석
- 장부 및 재고 관리
- AI 운영 전략 추천
- 전략 적용 효과 검증
- 리뷰 통계 및 AI 분석
- 고객 및 리포트 조회
- 커머스 및 상품 이미지 관리
- 계정 정보 관리

### 관리자

- 전체 매장 포트폴리오 조회
- 매장별 상세 현황 확인
- 위험 매장 모니터링
- 매출 목표 관리
- 공지사항 관리
- 서비스 상태 확인
- 점주·관리자 계정 및 초대 관리
- IAM 감사 로그 조회

일부 관리자 기능은 `SUPER_ADMIN` 권한에서만 사용할 수 있습니다.

---

## 이 저장소가 하는 일

**Market Poke** 운영 인프라를 Terraform으로 관리하는 저장소입니다.

AWS 위에 VPC부터 ECS Fargate, RDS, CloudFront, CI/CD용 IAM Role까지 전부 코드로 정의합니다.

- 네트워크 격리 — 데이터 계층을 인터넷에서 완전히 분리
- 컨테이너 오케스트레이션 — ECS Fargate 4개 서비스
- 데이터 저장소 — RDS MySQL, ElastiCache Redis
- 정적 호스팅과 CDN — S3 + CloudFront
- 비밀 관리 — Secrets Manager, 평문 비밀번호 없음
- CI/CD 인증 — GitHub Actions OIDC, 장기 Access Key 없음

### 관련 저장소

| 저장소 | 역할 |
| --- | --- |
| [BP20-FE](https://github.com/AIVLE-07-20-big-project/BP20-FE) | React 프론트엔드 |
| [BP20-BE](https://github.com/AIVLE-07-20-big-project/BP20-BE) | Spring Boot API 서버 |
| [BP20-AI](https://github.com/AIVLE-07-20-big-project/BP20-AI) | FastAPI AI 서버, Celery Worker·Beat |

---

## 아키텍처
<img width="4321" height="2342" alt="Image" src="https://github.com/user-attachments/assets/1e4268bb-ba15-4303-8f7e-6fb19af18ae4" />


### 설계 원칙

**외부 노출은 CloudFront와 ALB로만 한정합니다.** RDS·Redis·FastAPI·Celery는 프라이빗 서브넷에 있고 퍼블릭 IP가 없습니다. 아웃바운드가 필요한 경우에만 NAT Gateway를 거칩니다.

**프론트엔드와 API를 같은 Origin으로 제공합니다.** CloudFront가 정적 파일과 `/api/*`를 함께 서빙해 Mixed Content와 CORS 문제를 구조적으로 없앴습니다.

**서비스 간 통신은 Cloud Map을 사용합니다.** Spring → FastAPI, AI → Spring 내부 API 모두 `*.bp20.local` 내부 DNS로 연결됩니다. ALB를 우회하므로 인터넷 경로를 타지 않습니다.

**비밀은 Secrets Manager에만 둡니다.** JWT 서명 키, DB 비밀번호, 외부 API 키는 ECS Task Definition의 `secrets` 필드로 주입되며 이미지나 Git에 남지 않습니다.

---

## 저장소 구조

```
.
├── backend.tf              # S3 원격 상태 + 네이티브 잠금
├── providers.tf            # AWS Provider, 공통 태그
├── versions.tf             # Terraform · Provider 버전 제약
├── main.tf                 # 모듈 조립
├── variables.tf            # 입력 변수 정의
├── outputs.tf              # 엔드포인트 · ARN 출력
├── locals.tf               # name_prefix, 공통 태그
├── environments/
│   └── prod/
│       └── terraform.tfvars
├── modules/
└── docs/                   # 단계별 구축 가이드
```

### 모듈

| 모듈 | 관리 리소스 |
| --- | --- |
| `network` | VPC, Subnet 6개(public·app·data × 2AZ), IGW, NAT Gateway, Route Table |
| `security` | Security Group 5종과 인바운드·아웃바운드 규칙 |
| `ecr` | Spring·AI 이미지 저장소, Lifecycle Policy |
| `secrets` | Secrets Manager 저장소 (Backend·AI) |
| `data` | RDS MySQL, ElastiCache Redis, Subnet Group |
| `ecs-platform` | ECS Cluster, IAM Role 연결, CloudWatch Log Group, Cloud Map Namespace |
| `ecs-services` | Task Definition 4개, ECS Service 4개, Service Discovery |
| `alb` | Application Load Balancer, Target Group, Listener |
| `web` | Frontend S3, CloudFront Distribution, OAC, SPA Rewrite Function |
| `github-oidc` | OIDC Provider, 저장소별 배포 Role 3종 |

### 주요 스펙

| 항목 | 값 |
| --- | --- |
| 리전 | `ap-northeast-2` (서울) |
| VPC CIDR | `10.20.0.0/16`, 가용 영역 2개 |
| ECS | Fargate, `awsvpc`, Platform 1.4.0 |
| RDS | MySQL `db.t4g.micro`, gp3 20GB, Single-AZ |
| Redis | `cache.t4g.micro`, 노드 1개 |
| Terraform | `>= 1.10.0, < 2.0.0` |
| AWS Provider | `>= 5.0, < 7.0` |

RDS는 비용을 고려한 Single-AZ 구성입니다. 상용 환경이라면 Multi-AZ를 권장합니다.


## 실행 방법

### 사전 준비

- Terraform 1.10 이상
- AWS CLI v2, IAM Identity Center(SSO) 프로필 설정
- 상태 저장용 S3 버킷 (`backend.tf` 참고)

### 1. 자격 증명

```bash
aws sso login --profile bp20
```

```bash
export AWS_PROFILE=bp20 AWS_REGION=ap-northeast-2 AWS_DEFAULT_REGION=ap-northeast-2 AWS_SDK_LOAD_CONFIG=1
```

계정이 맞는지 확인합니다.

```bash
aws sts get-caller-identity
```

### 2. 초기화

```bash
terraform init
```

### 3. 검증

코드를 변경한 뒤에는 항상 이 순서로 확인합니다.

```bash
terraform fmt -recursive
```

```bash
terraform validate
```

### 4. 계획과 적용

```bash
terraform plan -var-file=environments/prod/terraform.tfvars -out=prod.tfplan
```

```bash
terraform show prod.tfplan
```

계획을 직접 확인한 뒤에만 적용합니다.

```bash
terraform apply prod.tfplan
```

---

## 애플리케이션 배포

Terraform은 인프라만 관리합니다.
컨테이너 이미지 빌드와 배포는 각 저장소의 GitHub Actions가 담당합니다.

| 변경 대상 | 방법 |
| --- | --- |
| 애플리케이션 코드 | 각 저장소 Actions → `Run workflow` |
| 인프라 (환경 변수·리소스) | 이 저장소에서 `terraform apply` |

### GitHub Actions OIDC

배포 워크플로는 장기 Access Key 대신 OIDC로 짧은 수명의 자격 증명을 발급받습니다. Trust Policy가 저장소와 Environment를 고정합니다.

```
repo:AIVLE-07-20-big-project/BP20-BE:environment:prod
```

Role ARN은 apply 후 출력에서 확인해 각 저장소의 `prod` Environment 변수에 등록합니다.

```bash
terraform output github_deploy_role_arns
```

> **Deployment branches 제한이 필요합니다.** Trust Policy의 `sub` 조건은 Environment만 구분하고 브랜치는 구분하지 않습니다. 각 저장소 `prod` Environment에서 배포 가능 브랜치를 `main`으로 제한해야 실질적인 방어가 됩니다.

### Task Definition 갱신 정책

ECS Service에는 다음 설정이 있습니다.

```hcl
lifecycle {
  ignore_changes = [task_definition, desired_count]
}
```

CI/CD가 배포한 이미지 리비전을 Terraform이 되돌리지 않습니다. 같은 이유로 `terraform apply`만으로는 새 Task Definition이 서비스에 반영되지 않으며, 인프라 변경 후에는 강제 배포가 필요합니다.

```bash
aws ecs update-service --cluster bp20-prod-cluster --service bp20-prod-spring --task-definition bp20-prod-spring --force-new-deployment --region ap-northeast-2
```

## 운영

### 비용 절감

`desired_count`가 `ignore_changes` 대상이므로 CLI로 조정해도 Terraform이 되돌리지 않습니다. 사용하지 않는 시간대에 Fargate 태스크를 0으로 내리면 비용의 대부분을 절약할 수 있습니다.

```bash
aws ecs update-service --cluster bp20-prod-cluster --service bp20-prod-spring --desired-count 0 --region ap-northeast-2
```

> NAT Gateway·ALB·ElastiCache는 태스크를 내려도 계속 과금됩니다. FastAPI는 모델 로딩 때문에 재기동에 5~10분이 걸립니다.

### 로그

```bash
aws logs tail /ecs/bp20-prod/spring-boot --since 10m --follow --region ap-northeast-2
```

로그 그룹은 서비스별로 분리되어 있습니다.

```
/ecs/bp20-prod/spring-boot
/ecs/bp20-prod/fastapi
/ecs/bp20-prod/celery-worker
/ecs/bp20-prod/celery-beat
```

## 팀

**AIVLE School AI 충남충북 20조** — 박형우(팀장), 박선호, 박승훈, 박유경, 박희상, 이상준

인프라 구성 및 CI/CD 파이프라인: 박유경
