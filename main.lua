-- I will make 3D tick tack toe

-- idk how to make the tilemap

push = require 'push'

-- functions take up so much space
require 'usefulFunctions'

-- size of our actual window
WINDOW_WIDTH = 800
WINDOW_HEIGHT = 600
-- WINDOW_WIDTH, WINDOW_HEIGHT = love.window.getDesktopDimensions()

-- size we're trying to emulate with push
VIRTUAL_WIDTH = 800
VIRTUAL_HEIGHT = 600

function love.load()
    love.window.setTitle('3D Tic Tac Toe')

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    love.graphics.setDefaultFilter('nearest', 'nearest')
    math.randomseed(os.time())
    randomColour = math.random(80, 120) / 255
    
    smallFont = love.graphics.newFont('WindowsRegular.ttf', 16)
    mediumFont = love.graphics.newFont('WindowsRegular.ttf', 32)
    largeFont = love.graphics.newFont('WindowsRegular.ttf', 128)

    sounds = {
        ['select1'] = love.audio.newSource('select1.wav', 'static'),
        ['select2'] = love.audio.newSource('select2.wav', 'static'),
        ['win'] = love.audio.newSource('win.wav', 'static'),
        ['enter'] = love.audio.newSource('enter.wav', 'static')
    }

    --[[ x1,y1    x2,y2
    
         x4,y4    x3,y3 ]] 

    verticesToPrint = {}
    for j = 0,2 do -- go down to another table
        for i = 0,2 do -- go down for each table
            local topSide = 40 * (1.5^i)
            local bottomSide = 60 * (1.5^i)
            local height = 30 * (1.5^i)
            local yPosition = 60 * (1.5^i) - 10 + 180 * j
            local idNumber = 2 + 3 * i + 9 * j
            local pinnacleY = yPosition - 60 - 30 * i -- I got 60 from trigonometry
            
            if i == 2 then
                pinnacleY = pinnacleY - 15 -- I'm so sorry for this
            end

            local pointsOnQuad2 = getverticesToPrint('left', topSide, bottomSide, height, yPosition, pinnacleY, idNumber - 1)
            table.insert(verticesToPrint, pointsOnQuad2)

            local pointsOnQuad = getverticesToPrint('middle', topSide, bottomSide, height, yPosition, pinnacleY, idNumber)
            table.insert(verticesToPrint, pointsOnQuad)

            local pointsOnQuad3 = getverticesToPrint('right', topSide, bottomSide, height, yPosition, pinnacleY, idNumber + 1)
            table.insert(verticesToPrint, pointsOnQuad3)
        end
    end
    
    playerTurn = 1

    P1Tiles = {}
    P2Tiles = {}

    selectedTileid = nil

    gameState = 'menu'
    gameEnd = false
    gameWinner = nil
    showStuff = false

end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    if key == 'f' then
        push:switchFullscreen(w, h)
    end

    if key == 'return' and gameState == 'menu' then
        gameState = 'play'
        sounds['enter']:play()
    end

    if gameState == 'play' then
        if key == 'r' then
            P1Tiles = {}
            P2Tiles = {}
            gameEnd = false
            gameWinner = nil
        end

        if key == '.' then
            showStuff = not showStuff
        end
    end

    
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.mousereleased(x, y, button)
    if button == 1 and gameState == 'menu' then
        gameState = 'play'
        sounds['enter']:play()
    end
 end

function love.mousepressed(x, y, button, istouch)
    if gameEnd then
        return 
    end

    if gameState == 'play' then
        if button == 1 and selectedTileid ~= nil then
            if playerTurn == 1 then

                if inTable(P2Tiles, selectedTileid) or inTable(P1Tiles, selectedTileid) then
                    return
                end

                table.insert(P1Tiles, selectedTileid)
                if checkWin(P1Tiles) then
                    gameEnd = true
                    gameWinner = 1
                    sounds['win']:play()
                    return
                end
                sounds['select1']:play()
                playerTurn = 2
            else 

                if inTable(P1Tiles, selectedTileid) or inTable(P2Tiles, selectedTileid) then
                    return
                end

                table.insert(P2Tiles, selectedTileid)
                if checkWin(P2Tiles) then
                    gameEnd = true
                    gameWinner = 2
                    sounds['win']:play()
                    return
                end
                sounds['select2']:play()
                playerTurn = 1
            end
        end
    end

end

function love.update(dt)
    mouseX, mouseY = push:toGame(love.mouse.getPosition())

    for i = 1,27,3 do 
        if mouseY > verticesToPrint[i].y2 and mouseY < verticesToPrint[i].y3 then
            selectedTileid = verticesToPrint[i].id
            break
        else
            selectedTileid = nil
        end
    end

    if mouseX == nil or mouseY == nil then
        selectedTileid = nil
    end

    if selectedTileid ~= nil then
        distFromMid = mouseX - VIRTUAL_WIDTH/2
        distFromPin = mouseY - verticesToPrint[selectedTileid].pinnacleY
        mouseMidRatio = distFromMid / distFromPin

        if mouseMidRatio > -1 and mouseMidRatio < -1/3 then
            -- do nothing
        elseif mouseMidRatio > -1/3 and mouseMidRatio < 1/3 then
            selectedTileid = selectedTileid + 1
        elseif mouseMidRatio > 1/3 and mouseMidRatio < 1 then
            selectedTileid = selectedTileid + 2
        else 
            selectedTileid = nil
        end
            
    end

end

function love.draw()
    push:start()

    love.graphics.clear(0, randomColour, randomColour)

    if gameState == 'menu' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(mediumFont)
        love.graphics.printf("Press 'enter' to play", 0, 500, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then
        love.graphics.setLineWidth(2.5)
        for i = 1, #verticesToPrint do 
            love.graphics.polygon('line', verticesToPrint[i].x1, verticesToPrint[i].y1, verticesToPrint[i].x2, verticesToPrint[i].y2, verticesToPrint[i].x3, verticesToPrint[i].y3, verticesToPrint[i].x4, verticesToPrint[i].y4)
        end

        if selectedTileid ~= nil then
            local n = selectedTileid
            love.graphics.polygon('fill', verticesToPrint[n].x1, verticesToPrint[n].y1, verticesToPrint[n].x2, verticesToPrint[n].y2, verticesToPrint[n].x3, verticesToPrint[n].y3, verticesToPrint[n].x4, verticesToPrint[n].y4)
        end

        if showStuff then
            love.graphics.setFont(smallFont)
            love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
            love.graphics.print('Player ' .. tostring(playerTurn) .. "'s turn", 10, 25)
            love.graphics.print('Colour: ' .. tostring(randomColour), 10, 40) -- +15 y coordinates
            love.graphics.print('mouseX: ' .. tostring(mouseX), 10, 55)
            love.graphics.print('mouseY: ' .. tostring(mouseY), 10, 70)
            love.graphics.print('Selected Tile: ' .. tostring(selectedTileid), 10, 85)
            love.graphics.print('Distance from Mid: ' .. tostring(distFromMid), 10, 100)
            love.graphics.print('Distance from Pin: ' .. tostring(distFromPin), 10, 115)
            if selectedTileid ~= nil then
                love.graphics.print('Pinnacle Y: ' .. tostring(verticesToPrint[selectedTileid].pinnacleY), 10, 130)
            end
            love.graphics.print('Game End: ' .. tostring(gameEnd), 10, 145)
            love.graphics.print('Game Winner: ' .. tostring(gameWinner), 10, 160)
        else
            if not gameEnd then
                love.graphics.setFont(mediumFont)
                -- love.graphics.print('Player ' .. tostring(playerTurn) .. "'s turn", 10, 25)
                if playerTurn == 1 then
                    love.graphics.printf('Player ' .. tostring(playerTurn) .. "'s turn", 10, 10, VIRTUAL_WIDTH - 20, 'left')
                else
                    love.graphics.printf('Player ' .. tostring(playerTurn) .. "'s turn", 10, 10, VIRTUAL_WIDTH - 20, 'right')
                end
            end
        end

        love.graphics.setFont(smallFont)
        love.graphics.print('By Mr Space Sheep', 680, 580)

        drawSquares(P2Tiles, verticesToPrint)
        drawXs(P1Tiles, verticesToPrint)

        if gameEnd then
            love.graphics.setColor(1,1,1,1)
            love.graphics.setFont(mediumFont)
            love.graphics.printf('Player ' .. tostring(playerTurn) .. " wins!", 0, 10, VIRTUAL_WIDTH, 'center')
            love.graphics.printf("Press 'r' to restart ", 0, 560, VIRTUAL_WIDTH, 'center')
        end
    end

    push:finish()
end