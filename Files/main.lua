-- Import libraries
local json = require("dkjson")

-- Variables
local screen = "menu"
local score = 0
local totalScore = 0
local currentQuiz = nil
local questionIndex = 1
local timer = 0
local timeLimit = 10
local answer = ""
local characters = {}
local cheatSheetAlphabet = "hiragana"
local cheatSheet = false
local difficulties = { easy = 10, medium = 5, hard = 3 }
local selectedDifficulty = "easy"
local alphabetType = "hiragana"
local font
local smallFont
local tinyFont
local pauseMenu = false
local backspaceHeld = false
local backspaceHoldTime = 0
local backspaceRepeatDelay = 0.1

-- Full Hiragana and Katakana tables
local hiragana = {
    { char = "あ", romaji = "a" }, { char = "い", romaji = "i" }, { char = "う", romaji = "u" }, { char = "え", romaji = "e" }, { char = "お", romaji = "o" },
    { char = "か", romaji = "ka" }, { char = "き", romaji = "ki" }, { char = "く", romaji = "ku" }, { char = "け", romaji = "ke" }, { char = "こ", romaji = "ko" },
    { char = "さ", romaji = "sa" }, { char = "し", romaji = "shi" }, { char = "す", romaji = "su" }, { char = "せ", romaji = "se" }, { char = "そ", romaji = "so" },
    { char = "た", romaji = "ta" }, { char = "ち", romaji = "chi" }, { char = "つ", romaji = "tsu" }, { char = "て", romaji = "te" }, { char = "と", romaji = "to" },
    { char = "な", romaji = "na" }, { char = "に", romaji = "ni" }, { char = "ぬ", romaji = "nu" }, { char = "ね", romaji = "ne" }, { char = "の", romaji = "no" },
    { char = "は", romaji = "ha" }, { char = "ひ", romaji = "hi" }, { char = "ふ", romaji = "fu" }, { char = "へ", romaji = "he" }, { char = "ほ", romaji = "ho" },
    { char = "ま", romaji = "ma" }, { char = "み", romaji = "mi" }, { char = "む", romaji = "mu" }, { char = "め", romaji = "me" }, { char = "も", romaji = "mo" },
    { char = "や", romaji = "ya" }, { char = "ゆ", romaji = "yu" }, { char = "よ", romaji = "yo" }, { char = "ら", romaji = "ra" }, { char = "り", romaji = "ri" },
    { char = "る", romaji = "ru" }, { char = "れ", romaji = "re" }, { char = "ろ", romaji = "ro" }, { char = "わ", romaji = "wa" }, { char = "を", romaji = "wo" },
    { char = "ん", romaji = "n" }
}

local katakana = {
    { char = "ア", romaji = "a" }, { char = "イ", romaji = "i" }, { char = "ウ", romaji = "u" }, { char = "エ", romaji = "e" }, { char = "オ", romaji = "o" },
    { char = "カ", romaji = "ka" }, { char = "キ", romaji = "ki" }, { char = "ク", romaji = "ku" }, { char = "ケ", romaji = "ke" }, { char = "コ", romaji = "ko" },
    { char = "サ", romaji = "sa" }, { char = "シ", romaji = "shi" }, { char = "ス", romaji = "su" }, { char = "セ", romaji = "se" }, { char = "ソ", romaji = "so" },
    { char = "タ", romaji = "ta" }, { char = "チ", romaji = "chi" }, { char = "ツ", romaji = "tsu" }, { char = "テ", romaji = "te" }, { char = "ト", romaji = "to" },
    { char = "ナ", romaji = "na" }, { char = "ニ", romaji = "ni" }, { char = "ヌ", romaji = "nu" }, { char = "ネ", romaji = "ne" }, { char = "ノ", romaji = "no" },
    { char = "ハ", romaji = "ha" }, { char = "ヒ", romaji = "hi" }, { char = "フ", romaji = "fu" }, { char = "ヘ", romaji = "he" }, { char = "ホ", romaji = "ho" },
    { char = "マ", romaji = "ma" }, { char = "ミ", romaji = "mi" }, { char = "ム", romaji = "mu" }, { char = "メ", romaji = "me" }, { char = "モ", romaji = "mo" },
    { char = "ヤ", romaji = "ya" }, { char = "ユ", romaji = "yu" }, { char = "ヨ", romaji = "yo" }, { char = "ラ", romaji = "ra" }, { char = "リ", romaji = "ri" },
    { char = "ル", romaji = "ru" }, { char = "レ", romaji = "re" }, { char = "ロ", romaji = "ro" }, { char = "ワ", romaji = "wa" }, { char = "ヲ", romaji = "wo" },
    { char = "ン", romaji = "n" }
}

-- Helper functions
local function saveScore()
    local file = love.filesystem.newFile("score.json", "w")
    file:write(json.encode({ totalScore = totalScore }))
    file:close()
end

local function loadScore()
    if love.filesystem.getInfo("score.json") then
        local file = love.filesystem.read("score.json")
        local data = json.decode(file)
        totalScore = data.totalScore or 0
    end
end

local function startQuiz(alphabet)
    alphabetType = alphabet
    characters = (alphabet == "hiragana") and hiragana or katakana
    currentQuiz = {}
    for i = 1, 25 do
        table.insert(currentQuiz, characters[love.math.random(#characters)])
    end
    questionIndex = 1
    timer = timeLimit
    score = 0
    screen = "quiz"
end

-- LOVE functions
function love.load()
    -- Load font
    font = love.graphics.newFont("NotoSerifCJKjp-VF.ttf", 20)
    smallFont = love.graphics.newFont("NotoSerifCJKjp-VF.ttf", 14)
    tinyFont = love.graphics.newFont("NotoSerifCJKjp-VF.ttf", 10)
    love.graphics.setFont(font)
    loadScore()
end

function love.update(dt)
    if screen == "quiz" and not pauseMenu and timer > 0 then
        timer = timer - dt
        if timer <= 0 then
            screen = "menu"
        end
    end

    if backspaceHeld then
        backspaceHoldTime = backspaceHoldTime + dt
        if backspaceHoldTime >= backspaceRepeatDelay then
            answer = answer:sub(1, -2)
            backspaceHoldTime = 0
        end
    end
end

function love.draw()
    -- Display escape info on all screens except menu
    if screen ~= "menu" then
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press Escape to return to the menu", 10, 10, love.graphics.getWidth(), "left")
        love.graphics.setFont(font)
    end

    if screen == "menu" then
        love.graphics.printf("Welcome to Kana Quiz!", 0, 20, love.graphics.getWidth(), "center")
        love.graphics.printf("1: Hiragana Quiz\n2: Katakana Quiz\n3: Cheat Sheet\n4: Quit", 0, 60, love.graphics.getWidth(), "center")
        love.graphics.printf("Total Score: " .. totalScore, 0, love.graphics.getHeight() - 40, love.graphics.getWidth(), "center")
    elseif screen == "difficulty" then
        love.graphics.printf("Choose Difficulty", 0, 20, love.graphics.getWidth(), "center")
        love.graphics.printf("1: Easy\n2: Medium\n3: Hard", 0, 60, love.graphics.getWidth(), "center")
    elseif screen == "quiz" then
        if pauseMenu then
            love.graphics.printf("Pause", 0, 20, love.graphics.getWidth(), "center")
            love.graphics.printf("Are you sure you want to return to the menu?\nPress Y to confirm or N to cancel.", 0, 60, love.graphics.getWidth(), "center")
        else
            local currentChar = currentQuiz[questionIndex]
            love.graphics.printf("What is the romanization of: " .. currentChar.char, 0, 20, love.graphics.getWidth(), "center")
            love.graphics.printf("Time left: " .. math.ceil(timer), 0, 60, love.graphics.getWidth(), "center")
            love.graphics.printf("Your answer: " .. answer, 0, 100, love.graphics.getWidth(), "center")
            love.graphics.printf("Score: " .. score, 0, 140, love.graphics.getWidth(), "center")
        end
    elseif screen == "cheat" then
        love.graphics.printf("Cheat Sheet (" .. cheatSheetAlphabet .. ")", 0, 20, love.graphics.getWidth(), "center")
        love.graphics.setFont(tinyFont)
        love.graphics.printf("Use Left/Right to switch alphabets", 10, 40, love.graphics.getWidth(), "left")
        love.graphics.setFont(font)
        
        local y = 80
        local alphabetTable = (cheatSheetAlphabet == "hiragana") and hiragana or katakana
        local maxCharsPerRow = 5
        for i, char in ipairs(alphabetTable) do
            local row = math.floor((i - 1) / maxCharsPerRow)
            local col = (i - 1) % maxCharsPerRow
            love.graphics.printf(char.char .. " - " .. char.romaji, 100 + col * 150, y + row * 30, love.graphics.getWidth(), "left")
        end
    end
end

function love.keypressed(key)
    if screen == "menu" then
        if key == "1" then screen = "difficulty"; alphabetType = "hiragana" end
        if key == "2" then screen = "difficulty"; alphabetType = "katakana" end
        if key == "3" then screen = "cheat" end
        if key == "4" then love.event.quit() end
    elseif screen == "difficulty" then
        if key == "1" then selectedDifficulty = "easy"; timeLimit = difficulties.easy; startQuiz(alphabetType) end
        if key == "2" then selectedDifficulty = "medium"; timeLimit = difficulties.medium; startQuiz(alphabetType) end
        if key == "3" then selectedDifficulty = "hard"; timeLimit = difficulties.hard; startQuiz(alphabetType) end
        if key == "escape" then screen = "menu" end
    elseif screen == "quiz" then
        if pauseMenu then
            if key == "y" then screen = "menu"; pauseMenu = false end
            if key == "n" then pauseMenu = false end
        else
            if key == "escape" then pauseMenu = true end
            if key == "backspace" then
                answer = answer:sub(1, -2)
                backspaceHeld = true
                backspaceHoldTime = 0
            elseif key == "return" then
                local correctAnswer = currentQuiz[questionIndex].romaji
                if answer == correctAnswer then
                    if selectedDifficulty == "hard" then
                        score = score + 2
                    else
                        score = score + 1
                    end
                    totalScore = totalScore + score
                elseif selectedDifficulty == "hard" then
                    score = score - 1
                end
                questionIndex = questionIndex + 1
                answer = ""
                timer = timeLimit
                if questionIndex > #currentQuiz then
                    saveScore()
                    screen = "menu"
                end
            elseif #key == 1 and not love.keyboard.isDown("lshift", "rshift") then
                answer = answer .. key
            end
        end
    elseif screen == "cheat" then
        if key == "escape" then
            screen = "menu"
        elseif key == "right" then
            cheatSheetAlphabet = (cheatSheetAlphabet == "hiragana") and "katakana" or "hiragana"
        elseif key == "left" then
            cheatSheetAlphabet = (cheatSheetAlphabet == "katakana") and "hiragana" or "katakana"
        end
    end
end

function love.keyreleased(key)
    if key == "backspace" then
        backspaceHeld = false
    end
end
