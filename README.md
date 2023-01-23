### 전공과목 최적설계를 통해 진행했던 프로젝트 내용 및 후에 개인적으로 발전시킨 내용이 포함된 레포지토리입니다.

---

# 최적설계 프로젝트


### 1. 최적설계 주제

![image](https://user-images.githubusercontent.com/108641325/213972549-7fa833c8-ca93-423d-a342-3c30200f5327.png)

**=> 스피드 스케이트의 날(blade)을 평소의 경우와 추진할 때의 경우로 나누어서 설계해보고자 함.** 

---

### 2. 최적설계 문제 정의

![image](https://user-images.githubusercontent.com/108641325/213973372-47f0b062-c162-49f0-87cc-067050b4108c.png)

---

### 3. 최적설계 조건

**- 날에 분포하중이 작용(평소)**

![image](https://user-images.githubusercontent.com/108641325/213973709-41fda39a-2de2-4420-a998-d811057dcf23.png)

- nelx:100, nely:10, Distributed load = 1
- top_201702390_distributedload(100, 10, 0.7, 3.0, 1.2)
  - top(nelx, nely, volfrac, penal, rmin)
  
---  
  
**- 날에 분포하중 + 집중하중이 작용(추진 시 뒷발)**

![image](https://user-images.githubusercontent.com/108641325/213974315-74cd5ec0-dd07-4b97-8650-ff0fe40b5f44.png)

- nelx:100, nely:10, Distributed load = 1, Concentrated load = 102
- top_201702390_concentratedload(100, 10, 0.7, 3.0, 1.2)

---

### 4. 결과물

**- 날에 분포하중이 작용(평소)**

![top_201702390_distributedload](https://user-images.githubusercontent.com/108641325/213975329-0ba907a0-84c5-4e91-8553-f1f6e276d4aa.png)

---

**- 날에 분포하중 + 집중하중이 작용(추진 시 뒷발)**

![top_201702390_concentratedload](https://user-images.githubusercontent.com/108641325/213975468-9f36f9a2-6db6-4dd0-b0cf-e2f715e8bbee.png)

---

### 5. Develop 

**- 날에 분포하중 + 집중하중이 작용(추진 시 뒷발) + 고정점 2개 추가**

![image](https://user-images.githubusercontent.com/108641325/213985543-34d95a03-29fd-4fe9-88ef-cb854dfb78e0.png)

- nelx:100, nely:10, Distributed load = 1, Concentrated load = 102
- top_201702390_concentratedload2(100, 10, 0.7, 3.0, 1.2)

**=> 결과물**

![top_201702390_concentratedload2](https://user-images.githubusercontent.com/108641325/213981374-4314b5ab-facd-4b0d-87fd-6bbae076501d.png)

---

**- 날에 '대각선 방향'(45도)의 분포하중이 작용 + 고정점 2개 추가(결승선 통과시 앞 발을 쭉 내밀 때)**

![image](https://user-images.githubusercontent.com/108641325/213985905-51edaf49-1ef3-4a84-af07-1f757d0581f5.png)

- nelx:100, nely:10, Distributed load = 1(x방향 힘의 크기는 1*cos(45). y방향 힘의 크기는 1*sin(45))
- top_201702390_distributedload2(100, 10, 0.7, 3.0, 1.2)

**=> 결과물**

![top_201702390_distributedload2](https://user-images.githubusercontent.com/108641325/213983024-93e04565-946d-4be7-878f-993eeb89fd09.png)

---

### => 위 4개의 스케이트 날 형상을 적절히 조합하면 최적의 결과물을 만들 수 있을 것 같다. 

