-- Define the main function to be called from the main script
local function main(info)
    -- Now you can use 'info' table to access the information passed from the main script
    print("Place ID:", info.PlaceId)
    print("Place Name:", info.PlaceName)
    -- Use other information as needed
end

-- Call main function with the passed information
main(...)
