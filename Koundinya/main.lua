push = require 'push'
Class = require 'class'
require 'Ball'
require 'Paddle'
paddle_speed=200
WindowWidth=1280
WindowHeight=720
VirtualWidth=432
VirtualHeight=243

function love.load()
  love.graphics.setDefaultFilter('nearest','nearest')
  love.window.setTitle('PONG')
  math.randomseed(os.time())
  push:setupScreen(VirtualWidth, VirtualHeight,WindowWidth, WindowHeight, {
      fullscreen = false,
      resizable = true,
      vsync = true
  })

  smallfont=love.graphics.newFont('font.ttf', 8)
  scorefont=love.graphics.newFont('font.ttf', 32)
  largefont=love.graphics.newFont('font.ttf', 20)
  player1score=0
  player2score=0
  service = math.random(2)
  winner=0
  player1 = Paddle(10, 30, 5, 20)
  player2 = Paddle(VirtualWidth - 10, VirtualHeight - 30, 5, 20)
  ball = Ball(VirtualWidth / 2 - 2, VirtualHeight / 2 - 2, 4, 4)

  sounds = {
      ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
      ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
      ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
  }

  gamestate='start'
end

function love.update(dt)
  if gamestate == 'serve' then
    ball.dy = math.random(-50,50)
    if service == 1 then
      ball.dx = math.random(100,200)
    else
      ball.dx = -math.random(100,200)
    end
  elseif gamestate == 'play' then
    if ball:collision(player1) then
      ball.dx = -ball.dx *1.03
      ball.x = player1.x + 5
      if ball.dy < 0 then
        ball.dy = -math.random(10,150)
      else
        ball.dy = math.random(10,150)
      end
      sounds['paddle_hit']:play()
    end
    if ball:collision(player2) then
      ball.dx = -ball.dx *1.03
      ball.x = player2.x - 4
      if ball.dy < 0 then
        ball.dy = -math.random(10,150)
      else
        ball.dy = math.random(10,150)
      end
        sounds['paddle_hit']:play()
    end
    if ball.y <= 0 then
      ball.y = 0
      ball.dy = -ball.dy
        sounds['wall_hit']:play()
    end
    if ball.y >= VirtualHeight - 4 then
      ball.y = VirtualHeight - 4
      ball.dy = -ball.dy
        sounds['wall_hit']:play()
    end
    if ball.x < 0 then
      player2score = player2score + 1
      if player2score == 10 then
        winner = 2
        gamestate = 'done'
      else
        gamestate = 'serve'
        ball:reset()
        service = 1
      end
        sounds['score']:play()
    end
    if ball.x > VirtualWidth then
      player1score = player1score + 1
      if player1score == 10 then
        winner = 1
        gamestate = 'done'
      else
        gamestate = 'serve'
        ball:reset()
        service = 2
    end
      sounds['score']:play()
  end
end

  if love.keyboard.isDown('w') then
    player1.dy = -paddle_speed
  elseif love.keyboard.isDown('s') then
    player1.dy = paddle_speed
  else
    player1.dy = 0
  end
  --  TWO PLAYER VERSION
  --if love.keyboard.isDown('up') then
    --player2.dy = -paddle_speed
  --elseif love.keyboard.isDown('down') then
    --player2.dy = paddle_speed
  --else
    --player2.dy = 0
  --end
--  AI CONTROLLED RIGHT PADDLE VERSION
  if ball.y < player2.y then
    player2.dy = -paddle_speed
  elseif ball.y > player2.y + player2.width then
    player2.dy = paddle_speed
  else
    player2.dy = 0
  end
  if gamestate =='play' then
    ball:update(dt)
  end
  player1:update(dt)
  player2:update(dt)
end

function love.draw()
  push:apply('start')
  if gamestate == 'start' then
    love.graphics.setFont(smallfont)
    love.graphics.printf('WELCOME TO PONG !!!', 0, 10, VirtualWidth, 'center')
    love.graphics.printf('Press Enter to serve', 0, 20, VirtualWidth, 'center')
    love.graphics.setFont(scorefont)
    love.graphics.print(tostring(player1score),VirtualWidth/2-50,VirtualHeight/3)
    love.graphics.print(tostring(player2score),VirtualWidth/2+30,VirtualHeight/3)
  elseif gamestate == 'serve' then
    love.graphics.setFont(smallfont)
    love.graphics.printf('Player ' .. tostring(service) .. "'s service !", 0, 10, VirtualWidth, 'center')
    love.graphics.printf('Press Enter to serve', 0, 20, VirtualWidth, 'center')
    love.graphics.setFont(scorefont)
    love.graphics.print(tostring(player1score),VirtualWidth/2-50,VirtualHeight/3)
    love.graphics.print(tostring(player2score),VirtualWidth/2+30,VirtualHeight/3)
  elseif gamestate == 'play' then
  end
  if gamestate == 'done'  then
    love.graphics.setFont(largefont)
    love.graphics.printf('Player ' .. tostring(winner) .. ' wins !', 0, 10, VirtualWidth, 'center')
    love.graphics.printf('Press Enter to play again', 0, 40, VirtualWidth, 'center')
    love.graphics.printf('Press Escape to quit the game', 0, 70, VirtualWidth, 'center')
  end
  player1:render()
  player2:render()
  ball:render()

  push:apply('end')
end

function love.keypressed(key)
  if key=='escape' then
    love.event.quit()
  elseif key=='enter' or key=='return' then
    if gamestate=='start' then
      gamestate='serve'
    elseif gamestate == 'serve' then
      gamestate = 'play'
    elseif gamestate == 'done' then
      gamestate = 'start'
      ball:reset()
      service = math.random(2)
      player1score = 0
      player2score = 0
    end
  end
end

function love.resize(w, h)
  push:resize(w,h)
end
