function getverticesToPrint(position, topSide, bottomSide, height, yPosition, pinnacleY, idNumber)
    if position == 'middle' then
        tableOfPoints = {
            x1 = (VIRTUAL_WIDTH - topSide)/2, y1 = yPosition, 
            x2 = (VIRTUAL_WIDTH + topSide)/2, y2 = yPosition,
            x3 = (VIRTUAL_WIDTH + bottomSide)/2, y3 = yPosition + height,
            x4 = (VIRTUAL_WIDTH - bottomSide)/2, y4 = yPosition + height, 
            pinnacleY = pinnacleY,
            id = idNumber
        }
    elseif position == 'left' then
        tableOfPoints = {
            x1 = (VIRTUAL_WIDTH - 3 * topSide)/2, y1 = yPosition, 
            x2 = (VIRTUAL_WIDTH - topSide)/2, y2 = yPosition,
            x3 = (VIRTUAL_WIDTH - bottomSide)/2, y3 = yPosition + height,
            x4 = (VIRTUAL_WIDTH - 3 * bottomSide)/2, y4 = yPosition + height, 
            pinnacleY = pinnacleY,
            id = idNumber
        }
    elseif position == 'right' then
        tableOfPoints = {
            x1 = (VIRTUAL_WIDTH + 3 * topSide)/2, y1 = yPosition, 
            x2 = (VIRTUAL_WIDTH + topSide)/2, y2 = yPosition,
            x3 = (VIRTUAL_WIDTH + bottomSide)/2, y3 = yPosition + height,
            x4 = (VIRTUAL_WIDTH + 3 * bottomSide)/2, y4 = yPosition + height,
            pinnacleY = pinnacleY, 
            id = idNumber
        }
    end

    return tableOfPoints
end

function checkWin(tileset)
    -- split tileset to the individual 2d boards
    local topBoard = {}
    local midBoard = {}
    local botBoard = {}

    for i = 1, #tileset do
        if tileset[i] < 10 then
            table.insert(topBoard, tileset[i])
        elseif tileset[i] > 9 and tileset[i] < 19 then
            table.insert(midBoard, tileset[i] - 9)
        else
            table.insert(botBoard, tileset[i] - 18)
        end
    end

    -- make function to check 2d board
    if checkFlatBoard(topBoard) or checkFlatBoard(midBoard) or checkFlatBoard(botBoard) then
        return true
    end

    -- make function to check 3d board (maybe check this before checkFlatBoard)
    if checkFullBoard(tileset) then
        return true
    end
end

function checkFlatBoard(flatBoard)
    for i = 0, 2 do
        -- check horizontal
        if inTable(flatBoard, 1 + i * 3) and inTable(flatBoard, 2 + i * 3) and inTable(flatBoard, 3 + i * 3) then
            return true
        end

        -- check verticle
        if inTable(flatBoard, 1 + i) and inTable(flatBoard, 4 + i) and inTable(flatBoard, 7 + i) then
            return true
        end
    end

    -- check diagonal
    if inTable(flatBoard, 1) and inTable(flatBoard, 5) and inTable(flatBoard, 9) then
        return true
    end
    if inTable(flatBoard, 3) and inTable(flatBoard, 5) and inTable(flatBoard, 7) then
        return true
    end

end

function checkFullBoard(board)
    -- check straight down
    for i = 1, 9 do 
        if inTable(board, i) and inTable(board, 9 + i) and inTable(board, 18 + i) then
            return true
        end
    end

    -- check diagonals
    for i = 0,2 do
        -- top left to bottom right move back to forward
        if inTable(board, 1 + 3 * i) and inTable(board, 11 + 3 * i) and inTable(board, 21 + 3 * i) then
            return true
        end
        -- top right to bottom left move back to forward
        if inTable(board, 3 + 3 * i) and inTable(board, 11 + 3 * i) and inTable(board, 19 + 3 * i) then
            return true
        end
        -- top left away to bottom left close move right
        if inTable(board, 1 + i) and inTable(board, 13 + i) and inTable(board, 25 + i) then
            return true
        end
        -- top left close to bottom left away move right
        if inTable(board, 7 + i) and inTable(board, 13 + i) and inTable(board, 19 + i) then
            return true
        end
    end

    -- check cross
    if inTable(board, 1) and inTable(board, 14) and inTable(board, 27) then
        return true
    end
    if inTable(board, 3) and inTable(board, 14) and inTable(board, 25) then
        return true
    end
    if inTable(board, 7) and inTable(board, 14) and inTable(board, 21) then
        return true
    end
    if inTable(board, 9) and inTable(board, 14) and inTable(board, 19) then
        return true
    end
end

function inTable(table, numNeeded)
    for i = 1, #table do
        if table[i] == numNeeded then
            return true
        end
    end
end

-- for P1
function drawXs(table, verticesToPrint)
    for i = 1, #table do
        local n = table[i]

        local remainder = n - math.floor(n/9)*9

        --[[
        if remainder == 1 or remainder == 2 or remainder == 3 then
            m = 2
        elseif remainder == 4 or remainder == 5 or remainder == 6 then
            m = 3 
        elseif remainder == 7 or remainder == 8 or remainder == 0 then
            m = 4.5
        end ]]

        m = 0

        love.graphics.setColor(255/255, 51/255, 0/255 ,1)
        love.graphics.setLineWidth(7)
        -- love.graphics.polygon('fill', verticesToPrint[n].x1, verticesToPrint[n].y1, verticesToPrint[n].x2, verticesToPrint[n].y2, verticesToPrint[n].x3, verticesToPrint[n].y3, verticesToPrint[n].x4, verticesToPrint[n].y4)
        love.graphics.line(verticesToPrint[n].x1 + m, verticesToPrint[n].y1 + m, verticesToPrint[n].x3 - m, verticesToPrint[n].y3 - m)
        love.graphics.line(verticesToPrint[n].x2 - m, verticesToPrint[n].y2 + m, verticesToPrint[n].x4 + m, verticesToPrint[n].y4 - m)
    end
end

-- for P2
function drawSquares(table, verticesToPrint)
    for i = 1, #P2Tiles do
        local n = P2Tiles[i]
        love.graphics.setColor(2/255, 165/255, 255/255, 1)

        local remainder = n - math.floor(n/9)*9

        m = 0

        --[[
        if remainder == 1 or remainder == 2 or remainder == 3 then
            m = 2
        elseif remainder == 4 or remainder == 5 or remainder == 6 then
            m = 3 
        elseif remainder == 7 or remainder == 8 or remainder == 0 then
            m = 4.5
        end ]]
        love.graphics.setLineWidth(7)
        love.graphics.polygon('line', verticesToPrint[n].x1 + m, verticesToPrint[n].y1 + m, verticesToPrint[n].x2 - m, verticesToPrint[n].y2 + m, verticesToPrint[n].x3 - m, verticesToPrint[n].y3 - m, verticesToPrint[n].x4 + m, verticesToPrint[n].y4 - m)
    end
end