START TRANSACTION;

UPDATE xml_form_builder_form_associations 
SET template = '<?xml version="1.0" encoding="UTF-8"?><mods xmlns="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  xmlns:xlink="http://www.w3.org/1999/xlink" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-4.xsd"><location><physicalLocation type="primary">Islandora Development Library</physicalLocation></location></mods>'
WHERE form_name = 'Digital Repository Metadata';

COMMIT;
