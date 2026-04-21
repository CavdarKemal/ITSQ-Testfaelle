package cte.testfaelle.consistency.parser;

import cte.testfaelle.consistency.RefExportsBeschreibung;

public class SdfRefExportsParser extends DefaultRefExportsParser {
    private static final String TAG_CREFONUMMER = "supplier-ident-national>";
    private static final String TAG_STAMM_DATEN_FIRMA = "sdf-firmendaten>";
    private static final String TAG_UPDATE_ON_COMPANY = "update-on-company>";

    @Override
    public String getCrefoNummerString(String line) {
        return getStringForXmlTag(line, TAG_CREFONUMMER, 10);
    }

    @Override
    public RefExportsBeschreibung.REF_EXPORT_TYPE getRefExportType(String line) {
        if (existsXmlTAG(line, TAG_STAMM_DATEN_FIRMA) || existsXmlTAG(line, TAG_UPDATE_ON_COMPANY)) {
            return RefExportsBeschreibung.REF_EXPORT_TYPE.CREFO_DATEN_FIRMA;
        }
        return RefExportsBeschreibung.REF_EXPORT_TYPE.UNBEKANNT;
    }
}
