import cv2
from ultralytics import YOLO
import glob
import os

# 1. 모델 불러오기
model = YOLO('Animals.v1-roboflow-instant-1--eval-.yolov8/best.pt')

# 2. 이미지 폴더 경로 지정 (★ 본인의 경로로 수정해주세요!)
image_directory = "Animals_file" 
MAX_DISPLAY_WIDTH = 1000 
FIXED_WINDOW_TITLE = 'YOLOv8 Image Viewer' 

# 3. 인식할 이미지 파일 확장자 지정
image_files = []
image_files.extend(glob.glob(os.path.join(image_directory, '*.jpg')))
image_files.extend(glob.glob(os.path.join(image_directory, '*.png')))


if not image_files:
    print(f"오류: {image_directory} 경로에 이미지 파일이 없습니다.")
else:
    for file_path in image_files:
        print(f"\n[INFO] [START] 다음 파일을 처리합니다: {file_path}")
        
        img = cv2.imread(file_path)

        if img is None:
            print(f"경고: {os.path.basename(file_path)} 파일을 읽을 수 없어 건너뜁니다.")
            continue

        # 4. 모델 추론 (★ 이 부분이 수정되었습니다: conf=0.1 추가)
        # 신뢰도(Confidence)를 0.1로 낮춰서, 확신이 낮더라도 결과를 출력하게 강제합니다.
        results = model(img, conf=0.1)
        
        # 5. 결과 이미지(박스가 그려진) 생성 및 크기 조절
        annotated_frame = results[0].plot()
        height, width, _ = annotated_frame.shape
        display_frame = annotated_frame
        
        if width > MAX_DISPLAY_WIDTH:
            new_width = MAX_DISPLAY_WIDTH
            new_height = int(height * (new_width / width)) 
            display_frame = cv2.resize(annotated_frame, (new_width, new_height))
        
        # 6. 결과 창 띄우기 및 키보드 입력 대기
        cv2.imshow(FIXED_WINDOW_TITLE, display_frame)
        print(f"   [ACTION] 현재 파일: {os.path.basename(file_path)}. 'q' 또는 'ESC'로 종료.")
        
        key = cv2.waitKey(0)
        
        cv2.destroyWindow(FIXED_WINDOW_TITLE) 
        
        if key == ord('q') or key == 27: 
            break 
            
    cv2.destroyAllWindows()
    print("[INFO] 모든 이미지 처리가 완료되었습니다.")