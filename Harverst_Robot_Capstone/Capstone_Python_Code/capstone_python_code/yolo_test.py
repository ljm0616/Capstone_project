from ultralytics import YOLO


def main():
    # 1) data.yaml 위치 (★ 여기를 본인 경로에 맞게 꼭 수정해 주세요!)
    data_yaml_path = 'Animals.v1-roboflow-instant-1--eval-.yolov8/data.yaml'

    # 2) Pretrained YOLOv8n 불러오기 (COCO로 미리 학습된 가중치)
    model = YOLO('yolov8n.pt')   # 또는 이미 어느 정도 학습된 가중치가 있으면 그 .pt 파일 경로

    # 3) 전이학습(파인튜닝) 시작
    model.train(
        data=data_yaml_path,     # 위에서 지정한 data.yaml
        epochs=100,              # 학습 epoch 수 (원하면 50, 200 등으로 조절)
        imgsz=640,               # 입력 이미지 크기
        batch=16,                # 배치 크기 (GPU VRAM에 따라 조절)
        device="cpu",                # 0: 첫 번째 GPU, CPU만 있으면 "cpu" 또는 -1
        workers=0,               # Windows에서는 0 권장 (DataLoader worker 수)
        project="runs_my_first_project",  # 결과 저장 상위 폴더 이름
        name="yolov8n_transfer", # 이번 실험 이름 (runs_my_first_project/yolov8n_transfer/에 저장)
        pretrained=True,         # yolov8n.pt 기반 전이학습 (기본 True)
        save=True,               # 베스트/최종 가중치 저장
    )

    # 4) validation (val 데이터로 성능 평가)
    print("\n[INFO] Validation on val split...")
    model.val(
        data=data_yaml_path,
        split="val",             # 기본값이 val라서 생략 가능
    )

    # 5) test split으로 평가 (Roboflow에서 export된 test 폴더)
    print("\n[INFO] Evaluation on test split...")
    model.val(
        data=data_yaml_path,
        split="test",            # data.yaml의 test: ../test/images 사용
    )

    # 6) 학습된 모델로 예시 이미지 추론
    #    test 이미지 하나를 골라서 결과를 보고 싶다면:
    #    예: C:\dev\datasets\my-first-project\test\images\xxx.jpg
    test_image_path = 'Animals_file/amber-kipp-6JZ09actp80-unsplash.jpg'  # 필요 시 수정

    print("\n[INFO] Inference on one test image...")
    results = model.predict(
        source=test_image_path,
        conf=0.5,               # confidence threshold
        save=True,              # 결과 이미지 저장
        project="runs_my_first_project",
        name="yolov8n_infer",
    )

    print("\n[INFO] Done. Check 'runs_my_first_project' folder for results.")


if __name__ == "__main__":
    main()