if not arg[1] then
    print("Usage:\n"
        .. "arg[1] should be a github repository link\n"
        .. "arg[2] should be a destination folder")
    return
end

local repo_link = arg[1]
local destination = arg[2] or "."

function pull(repo_link, destination)
    local github_api_link = "https://api.github.com/repos"

    url_parts = {}
    for part in repo_link:gmatch("[^/]+") do
        table.insert(url_parts, part)
    end

    local github_root = "github.com"
    local github_root_index
    for index, part in ipairs(url_parts) do
        if part == github_root then
            github_root_index = index
        end
    end

    local owner = url_parts[github_root_index + 1]
    local repo_name = url_parts[github_root_index + 2]

    local request_link =
        github_api_link .. "/"
        .. owner .. "/"
        .. repo_name .. "/contents"
    if not http.checkURL(request_link) then
        error("Malformed URL:\n" .. request_link)
    end

    local git_repo_request = http.get(request_link)
    local repo = textutils.unserialiseJSON(git_repo_request.readAll())

    local to_pull = {}
    for _, file in ipairs(repo) do
        table.insert(to_pull, file)
    end

    local all_files = {}

    while #to_pull ~= 0 do
        if to_pull[1].type == "dir" then
            local folder_link = request_link .. "/" .. to_pull[1].name
            folder_link = folder_link:gsub("%s", "%%20")
            if not http.checkURL(folder_link) then
                error("Malformed URL:\n" .. folder_link)
            end

            local folder_result = http.get(folder_link).readAll()
            local folder = textutils.unserialiseJSON(folder_result)

            for _, file in ipairs(folder) do
                file.name = to_pull[1].name .. "/" .. file.name
                table.insert(to_pull, file)
            end
        elseif to_pull[1].type == "file" then
            table.insert(all_files, to_pull[1])
        end

        table.remove(to_pull, 1)
    end

    for _, file in ipairs(all_files) do
        print("Requesting "..file.name.."...")
        
        local download_request = http.get(file.download_url)
        while not download_request do
            sleep(1)
            download_request = http.get(file.download_url)
        end
        
        local file_download = download_request.readAll()

        local file_handle = fs.open(destination .. "/" .. file.name, "w")
        file_handle.write(file_download)
        file_handle.close()
    end
end

pull(repo_link, destination)
