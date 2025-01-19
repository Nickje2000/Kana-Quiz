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
local previousChar = nil -- To track the previously selected character
local previousGroup = nil -- To track the previously selected group

-- Full Hiragana and Katakana tables with groups
local hiragana = {
    { char = "あ", romaji = "a", group = "a" }, { char = "い", romaji = "i", group = "a" }, { char = "う", romaji = "u", group = "a" }, { char = "え", romaji = "e", group = "a" }, { char = "お", romaji = "o", group = "a" },
    { char = "か", romaji = "ka", group = "ka" }, { char = "き", romaji = "ki", group = "ka" }, { char = "く", romaji = "ku", group = "ka" }, { char = "け", romaji = "ke", group = "ka" }, { char = "こ", romaji = "ko", group = "ka" },
    { char = "さ", romaji = "sa", group = "sa" }, { char = "し", romaji = "shi", group = "sa" }, { char = "す", romaji = "su", group = "sa" }, { char = "せ", romaji = "se", group = "sa" }, { char = "そ", romaji = "so", group = "sa" },
    { char = "た", romaji = "ta", group = "ta" }, { char = "ち", romaji = "chi", group = "ta" }, { char = "つ", romaji = "tsu", group = "ta" }, { char = "て", romaji = "te", group = "ta" }, { char = "と", romaji = "to", group = "ta" },
    { char = "な", romaji = "na", group = "na" }, { char = "に", romaji = "ni", group = "na" }, { char = "ぬ", romaji = "nu", group = "na" }, { char = "ね", romaji = "ne", group = "na" }, { char = "の", romaji = "no", group = "na" },
    { char = "は", romaji = "ha", group = "ha" }, { char = "ひ", romaji = "hi", group = "ha" }, { char = "ふ", romaji = "fu", group = "ha" }, { char = "へ", romaji = "he", group = "ha" }, { char = "ほ", romaji = "ho", group = "ha" },
    { char = "ま", romaji = "ma", group = "ma" }, { char = "み", romaji = "mi", group = "ma" }, { char = "む", romaji = "mu", group = "ma" }, { char = "め", romaji = "me", group = "ma" }, { char = "も", romaji = "mo", group = "ma" },
    { char = "や", romaji = "ya", group = "ya" }, { char = "ゆ", romaji = "yu", group = "ya" }, { char = "よ", romaji = "yo", group = "ya" }, { char = "ら", romaji = "ra", group = "ra" }, { char = "り", romaji = "ri", group = "ra" },
    { char = "る", romaji = "ru", group = "ra" }, { char = "れ", romaji = "re", group = "ra" }, { char = "ろ", romaji = "ro", group = "ra" }, { char = "わ", romaji = "wa", group = "wa" }, { char = "を", romaji = "wo", group = "wa" },
    { char = "ん", romaji = "n", group = "n" }
}

local katakana = {
    { char = "ア", romaji = "a", group = "a" }, { char = "イ", romaji = "i", group = "a" }, { char = "ウ", romaji = "u", group = "a" }, { char = "エ", romaji = "e", group = "a" }, { char = "オ", romaji = "o", group = "a" },
    { char = "カ", romaji = "ka", group = "ka" }, { char = "キ", romaji = "ki", group = "ka" }, { char = "ク", romaji = "ku", group = "ka" }, { char = "ケ", romaji = "ke", group = "ka" }, { char = "コ", romaji = "ko", group = "ka" },
    { char = "サ", romaji = "sa", group = "sa" }, { char = "シ", romaji = "shi", group = "sa" }, { char = "ス", romaji = "su", group = "sa" }, { char = "セ", romaji = "se", group = "sa" }, { char = "ソ", romaji = "so", group = "sa" },
    { char = "タ", romaji = "ta", group = "ta" }, { char = "チ", romaji = "chi", group = "ta" }, { char = "ツ", romaji = "tsu", group = "ta" }, { char = "テ", romaji = "te", group = "ta" }, { char = "ト", romaji = "to", group = "ta" },
    { char = "ナ", romaji = "na", group = "na" }, { char = "ニ", romaji = "ni", group = "na" }, { char = "ヌ", romaji = "nu", group = "na" }, { char = "ネ", romaji = "ne", group = "na" }, { char = "ノ", romaji = "no", group = "na" },
    { char = "ハ", romaji = "ha", group = "ha" }, { char = "ヒ", romaji = "hi", group = "ha" }, { char = "フ", romaji = "fu", group = "ha" }, { char = "ヘ", romaji = "he", group = "ha" }, { char = "ホ", romaji = "ho", group = "ha" },
    { char = "マ", romaji = "ma", group = "ma" }, { char = "ミ", romaji = "mi", group = "ma" }, { char = "ム", romaji = "mu", group = "ma" }, { char = "メ", romaji = "me", group = "ma" }, { char = "モ", romaji = "mo", group = "ma" },
    { char = "ヤ", romaji = "ya", group = "ya" }, { char = "ユ", romaji = "yu", group = "ya" }, { char = "ヨ", romaji = "yo", group = "ya" }, { char = "ラ", romaji = "ra", group = "ra" }, { char = "リ", romaji = "ri", group = "ra" },
    { char = "ル", romaji = "ru", group = "ra" }, { char = "レ", romaji = "re", group = "ra" }, { char = "ロ", romaji = "ro", group = "ra" }, { char = "ワ", romaji = "wa", group = "wa" }, { char = "ヲ", romaji = "wo", group = "wa" },
    { char = "ン", romaji = "n", group = "n" }
}

-- Helper functions
local function selectRandomCharacter(alphabet)
    local attempts = 0
    local char
    repeat
        char = alphabet[love.math.random(#alphabet)]
        attempts = attempts + 1
    until (char.char ~= previousChar and char.group ~= previousGroup) or attempts > 10
    previousChar = char.char
    previousGroup = char.group
    return char
end

local function startQuiz(alphabet)
    alphabetType = alphabet
    characters = (alphabet == "hiragana") and hiragana or katakana
    currentQuiz = {}
    for i = 1, 25 do
        table.insert(currentQuiz, selectRandomCharacter(characters))
    end
    questionIndex = 1
    timer = timeLimit
    score = 0
    screen = "quiz"
end

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
        love.graphics.printf("Press Esc to return to the menu", 10, 10, love.graphics.getWidth(), "left")
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