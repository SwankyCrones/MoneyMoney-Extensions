-- The MIT License (MIT)
--
-- Copyright (c) 2015 Joern Thiemann
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.

Exporter {version=1.00,
          format="Bar-Charts - Categories per Year",
          fileExtension="html"}

EXPORT_TYPE = 0

function WriteHeader (account, startDate, endDate, transactionCount)

    -- Write TSV description.
        --assert(io.write("Name", ";", "Amount", "\n"))

    if EXPORT_TYPE == 0 then
            assert(io.write("<!DOCTYPE html>\n"))
            assert(io.write("<html>\n"))
            assert(io.write("<head>\n"))
            assert(io.write("<meta charset=\"utf-8\">\n"))
            assert(io.write("<title>Finances</title>\n"))

                assert(io.write("<style>\n"))
            assert(io.write(".c3-tooltip {  border-collapse:collapse; border-spacing:0; background-color:#fff; empty-cells:show; -webkit-box-shadow: 7px 7px 12px -9px rgb(119,119,119); -moz-box-shadow: 7px 7px 12px -9px rgb(119,119,119); box-shadow: 7px 7px 12px -9px rgb(119,119,119); opacity: 0.9; }\n"))
            assert(io.write(".c3-tooltip tr {  border:1px solid #CCC;}\n"))
            assert(io.write(".c3-tooltip th {  background-color: #aaa;  font-size:14px;  padding:2px 5px;  text-align:left;  color:#FFF;}\n"))
            assert(io.write(".c3-tooltip td {  font-size:13px;  padding: 3px 6px;  background-color:#fff;  border-left:1px dotted #999;}\n"))
            assert(io.write(".c3-tooltip td > span {  display: inline-block;  width: 10px;  height: 10px;  margin-right: 6px;}\n"))
            assert(io.write(".c3-tooltip td.value{  text-align: right;}\n"))
            assert(io.write(".c3-area {  stroke-width: 0;  opacity: 0.0;}\n"))
            assert(io.write("\n"))
            assert(io.write(".c3 svg {  font: 10px sans-serif; }\n"))
            assert(io.write(".c3 path, .c3 line {  fill: none;  stroke: #000;}\n"))
            assert(io.write(".c3 text {  -webkit-user-select: none; -moz-user-select: none; user-select: none; }\n"))
            assert(io.write(".c3-chart-arc path {  stroke: #fff; }\n"))
            assert(io.write(".c3-chart-arc text { fill: #fff; font-size: 13px; }\n"))
            assert(io.write("\n"))
            assert(io.write(".c3-axis-x .tick {}\n"))
            assert(io.write(".c3-axis-x-label {}\n"))
            assert(io.write(".c3-axis-y .tick {}\n"))
            assert(io.write(".c3-axis-y-label {}\n"))
            assert(io.write(".c3-axis-y2 .tick {}\n"))
            assert(io.write(".c3-axis-y2-label {}\n"))
            assert(io.write("\n"))
            assert(io.write(".c3-grid line {  stroke: #aaa; }\n"))
            assert(io.write(".c3-grid text {  fill: #aaa; }\n"))
            assert(io.write(".c3-xgrid, .c3-ygrid {  stroke-dasharray: 3 3; }\n"))
            assert(io.write(".c3-xgrid-focus {}\n"))
            assert(io.write("\n"))
            assert(io.write(".c3-line { stroke-width: 1px;}\n"))

                assert(io.write("</style>\n"))


            assert(io.write("<script type=\"text/javascript\" src=\"d3.min.js\"></script>\n"))
            assert(io.write("<script type=\"text/javascript\" src=\"c3.min.js\"></script>\n"))
            assert(io.write("</head>\n"))
            assert(io.write("<body>\n"))
    end

    categoryIndex = {}
    categoryIndexCount = 0
    amountPerCategory = {}
    summedAmountPerCategory = {}
    categoryHierarchy = {}
    startDate = -1
    minYear = -1
    maxYear = -1


end

function findCategory(category)

        index = -1

        -- assert(io.write("find ", category, "\n"))

        for i=0, categoryIndexCount-1 do
        -- assert(io.write("find ", category, " <-> ", categoryIndex[i], "\n"))
                if categoryIndex[i] == category then
                        index = i

                        -- assert(io.write("found", category, " ", index, "\n"))

                        break
                end
        end

        return index
end

function createCategory(category)

         categoryIndex[categoryIndexCount] = category
        amountPerCategory[categoryIndexCount] = {}

        count = 0
        pos = 1
        bEnd = false
        while bEnd == false do

                if string.find(category, "\\", pos) == nil then
                        bEnd = true
                end

                if bEnd == false then
                        startIndex, pos = string.find(category, "\\", pos)
                        pos = pos + 1
                end

                count = count + 1
        end

        categoryHierarchy[categoryIndexCount] = count;

        -- assert(io.write(category, count, "\n"))

        -- year 0 to year 9999
        for l=0, 9999 do
                amountPerCategory[categoryIndexCount][l] = 0
        end
        categoryIndexCount = categoryIndexCount + 1

        if string.find(category, "\\") ~= nil then
                category = calcParentCategory(category)
                if findCategory(category) == -1 then
                        createCategory(category)
                end
        end
end

function WriteTransactions (account, transactions)

    -- Write transactions.
    for _,transaction in ipairs(transactions) do

        year = tonumber(os.date("%Y", transaction.bookingDate))
        if minYear == -1 then
                minYear = year
               end
        if minYear > year then
                minYear = year
               end

        if maxYear == -1 then
                maxnYear = year
               end
        if maxYear < year then
                maxYear = year
               end

        -- assert(io.write(transaction.category, ";", year, "\n"))

        found = false
        for i=0, categoryIndexCount do
            if categoryIndex[i] == transaction.category then

                amountPerCategory[i][year] = amountPerCategory[i][year] + transaction.amount

                found = true
                break
            end
        end

        if found == false then

                createCategory(transaction.category)
                        amountPerCategory[findCategory(transaction.category)][year] = transaction.amount

        end

    end

end

function calcDisplayedCategory(fullCategory)

        bEnd = false
        displayedCategory = fullCategory
        while bEnd == false do

            if string.find(displayedCategory, "\\") == nil then
                    bEnd = true
            end
            if string.find(displayedCategory, "\\") ~= nil then
                    startIndex, pos = string.find(displayedCategory, "\\")
                    displayedCategory = string.sub(displayedCategory, pos + 1, string.len(displayedCategory))
            end
    end
    return displayedCategory
end

function calcHiearchyLevel(fullCategory)

        hiearchyLevel = 1
        bEnd = false
        displayedCategory = fullCategory
        while bEnd == false do

            if string.find(displayedCategory, "\\") == nil then
                    bEnd = true
            end
            if string.find(displayedCategory, "\\") ~= nil then
                    startIndex, pos = string.find(displayedCategory, "\\")
                    displayedCategory = string.sub(displayedCategory, pos + 1, string.len(displayedCategory))

                    hiearchyLevel = hiearchyLevel + 1
            end
    end
    return hiearchyLevel
end

function calcParentCategory(fullCategory)

        bEnd = false
        category = fullCategory
        startIndex = 1
        while bEnd == false do

            if string.find(fullCategory, "\\", startIndex) == nil then
                    category = string.sub(fullCategory, 1, startIndex - 2)
                    bEnd = true
            end
            if string.find(fullCategory, "\\", startIndex) ~= nil then
                    startIndex, pos = string.find(category, "\\", startIndex)
                    startIndex = startIndex + 1
            end

    end

    return category
end

function addToSummedCategory(category, year, amount)

           if string.find(category, "\\") ~= nil then
            startIndex, pos = string.find(category, "\\", -1)
            category = calcParentCategory(category)

            index = findCategory(category)
            if index ~= -1 then
                    summedAmountPerCategory[index][year] = summedAmountPerCategory[index][year] + amount
                        -- assert(io.write(category, year, "    ", summedAmountPerCategory[index][year], "   ", "\n"))
            end

                -- assert(io.write(category, year, "    ", amount, "   ", "\n"))
                addToSummedCategory(category, year, amount)
           end
end

function createChart(categoryForChart)

        generateChart = false
        currentHierarchy = calcHiearchyLevel(categoryForChart)

        for i=0,categoryIndexCount - 1 do

            bAdd = false

            usedCategory = calcDisplayedCategory(categoryIndex[i])

            if string.find(categoryIndex[i], categoryForChart) ~= nil then
                    startIndex, pos = string.find(categoryIndex[i], categoryForChart)
                    --assert(io.write(categoryIndex[i], startIndex, pos, "\n"))
                        if startIndex == 1 then
                                if categoryHierarchy[i] == currentHierarchy + 1 then
                                        bAdd = true

                                        generateChart = true
                                        break
                                end
                    end
            end
    end

        if generateChart == true then
                header = string.gsub(categoryForChart, "\\", " > ")
                assert(io.write(header))
                assert(io.write("<div id=\"chart", chartID, "\" style=\"width:97%\"></div>\n"))

                assert(io.write("<script>"))

                lstHiddenCharts = {}
                lstHiddenChartsSize = 0
                -- generate full chart
                assert(io.write("var chart = c3.generate({bindto: '#chart", chartID, "',size: {height:500 }, data: { x: 'x', columns: [\n"))

                                -- Write year
                                assert(io.write("['x',"))
                                for l=minYear, maxYear do
                                        assert(io.write("'", l, "-01-01'"))
                                        if l < maxYear then
                                                assert(io.write(","))
                                        end
                                end
                                assert(io.write("],\n"))

                for i=0,categoryIndexCount - 1 do

                        bAdd = false

                        usedCategory = calcDisplayedCategory(categoryIndex[i])

                        if string.find(categoryIndex[i], categoryForChart) ~= nil then
                                startIndex, pos = string.find(categoryIndex[i], categoryForChart)
                                --assert(io.write(categoryIndex[i], startIndex, pos, "\n"))
                                if startIndex == 1 then
                                        if categoryHierarchy[i] == currentHierarchy + 1 then
                                                bAdd = true
                                        end
                                end
                        end



                        if bAdd == true then


                                -- Write amounts
                                assert(io.write("['", usedCategory, "',"))
                                lstHiddenCharts[lstHiddenChartsSize] = usedCategory
                                lstHiddenChartsSize = lstHiddenChartsSize + 1
                                for l=minYear, maxYear do
                                        amountValue = tonumber(amountPerCategory[i][l] + summedAmountPerCategory[i][l])
                                        if amountValue < 0 then
                                                amountValue = -amountValue
                                        end

                                        amount = string.format("%.2f", amountValue)
                                        -- amount = string.gsub(amount, "%.", ",")

                                        --assert(io.write(amount))
                                        assert(io.write(amount))
                                        if l < maxYear then
                                                assert(io.write(","))
                                        end
                                end

                                assert(io.write("],\n"))
                        end

                end
                assert(io.write("],\n"))
                assert(io.write("type: 'bar', }, grid: { x: { show: true }, y: { show: true } },bar: { width: { ratio: 0.8 } }, axis: { x: { type: 'timeseries', tick: { format: '%Y' } },  y: { label: { text: 'Euro', position: 'outer-middle' } }, } });\n"))
                assert(io.write("chart.hide(["))

                for ii=0,lstHiddenChartsSize - 1 do
                        assert(io.write("'", lstHiddenCharts[ii], "',"))
                end
                assert(io.write("]);\n"))
                assert(io.write("</script>\n"))

                chartID = chartID + 1
        end
end

function WriteTail (account)

        -- create summed up amounts
    for i=0,categoryIndexCount - 1 do
              summedAmountPerCategory[i] = {}
               for l=minYear, maxYear do
                      summedAmountPerCategory[i][l] = 0
                end
        end

    for i=0,categoryIndexCount - 1 do
               for l=minYear, maxYear do
                      addToSummedCategory(categoryIndex[i], l, amountPerCategory[i][l])
                end
        end

        -- test debug output
    for i=0,categoryIndexCount - 1 do
               for l=minYear, maxYear do
                       -- assert(io.write(categoryIndex[i], "   ", l, "    ", summedAmountPerCategory[i][l], "\n"))
                end
        end


        -- create charts
        chartID = 0

        -- currently hard coded 15 levels
        for hierarchyLevel=1,15 do
            for i=0,categoryIndexCount - 1 do

                        if calcHiearchyLevel(categoryIndex[i]) == hierarchyLevel then
                                createChart(categoryIndex[i])
                        end

                end
        end

        assert(io.write("</body>\n"))
        assert(io.write("</html>\n"))

end

-- SIGNATURE: MC0CFDYavQXpomLygaB4d1TmHcAn912cAhUAhr7012w6jk2JyXZ6FQ3XHHsCBSE=
