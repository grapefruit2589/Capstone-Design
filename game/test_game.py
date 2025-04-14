#그림 짝 찾기 게임
import turtle as T
import random

HINT, RUNNING, TEMPVIEW, STOP   = 0, 1, 2, 3 # 게임 상태
HIDDEN, TEMP, FLIP = 0, 1, 2 # 셀 상태
class CoupleGame(T.Turtle):
    def __init__(self, nW=4, nH=4, bW=100, bH=100, M=20, gap=0,
                 pensize = 3, bgcolor='white'):

        self.imageList = []
        self.imageList.append('./image/shape0.gif')        
        self.imageList.append('./image/shape1.gif')
        self.imageList.append('./image/shape2.gif')
        self.imageList.append('./image/shape3.gif')
        self.imageList.append('./image/shape4.gif')
        self.imageList.append('./image/shape5.gif')
        self.imageList.append('./image/shape6.gif')
        self.imageList.append('./image/shape7.gif')
        self.imageList.append('./image/shape8.gif')           
        for image in self.imageList:            
            T.register_shape(image)  # 이미지 변경 예정

        W = 2*M+(nW-1)*gap+(nW*bW) # 스크린 크기 계산
        H = 2*M+(nH-1)*gap+(nH*bH)

        screen = T.Screen()
        screen.bgcolor(bgcolor)        
        screen.setup(W, H)
        T.setworldcoordinates(0, 0, W, H)

        self.canvas = screen.getcanvas()
        self.canvas.master.resizable(0,0)
        self.canvas.master.wm_attributes('-topmost', 1)

        self.bW = bW   # 블록 크기
        self.bH = bH  
        self.nW = nW
        self.nH = nH              
        self.M  = M
        self.gap = gap

        self.tx  = -1  # 마우스로 임시로 뒤집어 놓은 첫 TEMP셀 번호
        self.ty  = -1
        self.count = 0 # 시도 횟수
        # 터틀 생성
        self.turtle = [[ T.Turtle() for ix in range(nW)]
                                  for iy in range(nH)]        
        self.cell  = [[ 0 for ix in range(nW)] for  iy  in range(nH)]
        self.status = [[ 0 for ix in range(nW)] for iy  in range(nH)]
        
        random.seed() # 난수 초기화
        self.initGame(move=True) # 터틀을 움직임
         
        # 마우스, 키보드 이벤트 설정
        T.onscreenclick(self.onMouseLeftDown)
        T.onkey(self.onSpace, 'space')
        T.onkey(T.bye, 'Escape')
        T.listen()    
        
    def onSpace(self):  # 키보드 이벤트 처리
        if self.gameSatus == STOP:
            self.initGame() # 터틀 움직임 없이, 그림모양변경

    def onGameStart(self): # 타이머 이벤트 처리
        title = '게임상태: RUNNING'
        T.title(title)
        self.gameSatus = RUNNING
        self.drawBoard()

    def onTempView(self):  # 타이머 이벤트 처리
        self.tx = self.ty = -1 # TEMP 셀 없음 
        for iy in range(self.nH):
            for ix in range(self.nW):
                if self.status[iy][ix] == TEMP:
                    self.status[iy][ix]= HIDDEN
        self.gameSatus = RUNNING
        self.drawBoard()
        
    def countHidden(self):
        remain = self.nH*self.nW
        for iy in range(self.nH):
            for ix in range(self.nW):
                if self.status[iy][ix] == FLIP:
                    remain -= 1
        return remain

    def getClickCell2(self, x, y): # 블록(셀) 찾음
        for iy in range(self.nH):
            for ix in range(self.nW):
                x1 = self.M+(self.bW+self.gap)*ix
                y1 = self.M+(self.bH+self.gap)*iy
                x2 = x1 + self.bW
                y2 = y1 + self.bH
                if x1 <= x <=x2 and y1 <= y <= y2:
                    return ix, iy
        return -1, -1 # 외부 클릭
                             
    def onMouseLeftDown(self, x, y):
        if self.gameSatus != RUNNING:
            return
        ix, iy = self.getClickCell2(x, y)
        if ix < 0: # 선택 셀 없음 
            return    
        if self.status[iy][ix] != HIDDEN:
            return
        
        if self.tx == -1: # 임시로 뒤집어 놓은 셀이 없다면
            self.status[iy][ix] = TEMP
            self.tx = ix
            self.ty = iy
            self.drawBoard()
        else:  # 임시로 뒤집어 놓은 셀이 있으면
            self.count += 1 # 시도 횟수 카운트
            title = '시도횟수:' + str(self.count)
            T.title(title)
                
            if self.cell[self.ty][self.tx] == self.cell[iy][ix]:
                self.status[self.ty][self.tx] = FLIP
                self.status[iy][ix] = FLIP
                self.tx = self.ty = -1 # TEMP 셀 없음
                self.drawBoard()
                
                if self.countHidden() == 0:
                    self.gameSatus = STOP
                    title='게임상태: STOP' + ',총 시도횟수:'+ str(self.count)
                    T.title(title)
            else:
                self.status[iy][ix] = TEMP
                self.gameSatus    = TEMPVIEW
                self.drawBoard()
                T.ontimer(self.onTempView, 1000)  # 1초 타이머
                    
    def initGame(self, move=False):
        self.gameSatus = HINT
        self.count = 0 # 시도 횟수
        for iy in range(self.nH):
            for ix in range(self.nW):
                self.cell[iy][ix] = 0
                self.status[iy][ix]= HIDDEN                
        self.randomImagePair() 
        self.drawBoard(move)
        title = '게임상태: HINT'
        T.title(title)
        T.ontimer(self.onGameStart, 3000) # 3초 타이머 이벤트

    def randomImagePair(self): # 그림 쌍을 난수로 섞어서 배치
        for num in range(1, len(self.imageList)):     
            for k in range(2): # 2개의 짝
                emptyCell = True
                while emptyCell:
                    iy =  random.randrange(self.nH)
                    ix =  random.randrange(self.nW)
                    if self.cell[iy][ix] == 0:
                        emptyCell = False
                self.cell[iy][ix] = num

        # 2개 뽑아 섞기(shuffling)
        for k in range(100):
             iy1 =  random.randrange(self.nH)
             ix1 =  random.randrange(self.nW)
             iy2 =  random.randrange(self.nH)
             ix2 =  random.randrange(self.nW)
             
             if self.cell[iy1][ix1] != self.cell[iy2][ix2]:
                 t = self.cell[iy1][ix1]
                 self.cell[iy1][ix1] = self.cell[iy2][ix2]
                 self.cell[iy2][ix2] = t
                            
    def drawBlock(self, ix, iy, num, move):
        if move:           
            x1 = self.M+(self.bW+self.gap)*ix
            y1 = self.M+(self.bH+self.gap)*iy
            x2 = x1 + self.bW/2 # 블록중심
            y2 = y1 + self.bH/2
            
            self.turtle[iy][ix].up()
            self.turtle[iy][ix].st()
            self.turtle[iy][ix].setpos(x2, y2) # 블록중앙에 위치
        self.turtle[iy][ix].shape(self.imageList[num])
               
    def drawBoard(self, move=False):
        T.tracer(0) # 에니메이션 끄기
        for iy in range(self.nH):
            for ix in range(self.nW):
                if ( self.gameSatus == HINT or
                       self.status[iy][ix] != HIDDEN ):
                    num = self.cell[iy][ix]
                else:
                    num = 0
                self.drawBlock(ix, iy, num, move)
        T.update() #T.tracer(1)
if __name__ == '__main__':
    game = CoupleGame()
    T.mainloop()
