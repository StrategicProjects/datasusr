
# ---- Internal catalog tables ------------------------------------------------

#' Internal DATASUS source catalog
#'
#' @return A tibble.
#' @keywords internal
.datasus_sources_tbl <- function() {
  tibble::tribble(
    ~source,            ~description,                                                                 ~default_scope, ~supports_month, ~supports_uf, ~access,     ~verified,
    "SIHSUS",           "SIHSUS - Sistema de Informacoes Hospitalares do SUS",                        "UF",           TRUE,            TRUE,         "fetch",     TRUE,
    "SIASUS",           "SIASUS - Sistema de Informacoes Ambulatoriais do SUS",                       "UF",           TRUE,            TRUE,         "fetch",     TRUE,
    "SIM",              "SIM - Sistema de Informacoes de Mortalidade",                                "TT",           FALSE,           TRUE,         "fetch",     TRUE,
    "CIH",              "CIH - Sistema de Comunicacao de Informacao Hospitalar",                      "UF",           TRUE,            TRUE,         "fetch",     FALSE,
    "CIHA",             "CIHA - Sistema de Comunicacao de Informacao Hospitalar e Ambulatorial",      "UF",           TRUE,            TRUE,         "fetch",     FALSE,
    "SINASC",           "SINASC - Sistema de Informacao de Nascidos Vivos",                           "TT",           FALSE,           TRUE,         "fetch",     TRUE,
    "SISPRENATAL",      "SISPRENATAL - Sistema de Monitoramento e Avaliacao do Pre-Natal",            "UF",           TRUE,            TRUE,         "fetch",     FALSE,
    "CNES",             "CNES - Cadastro Nacional de Estabelecimentos de Saude",                      "UF",           TRUE,            TRUE,         "fetch",     TRUE,
    "SINAN",            "SINAN - Sistema de Informacao de Agravos de Notificacao",                    "BR",           FALSE,           FALSE,        "fetch",     FALSE,
    "SINAN_P",          "SINAN preliminar - Sistema de Informacao de Agravos de Notificacao",         "BR",           FALSE,           FALSE,        "fetch",     FALSE,
    "ESUSNOTIFICA",     "e-SUS Notifica",                                                             "BR",           FALSE,           FALSE,        "fetch",     FALSE,
    "ESUSNOTIFICA_P",   "e-SUS Notifica preliminar",                                                  "BR",           FALSE,           FALSE,        "fetch",     FALSE,
    "RESP",             "RESP - Notificacoes de casos suspeitos de SCZ",                              "UF",           FALSE,           TRUE,         "fetch",     FALSE,
    "PO",               "PO - Painel de Oncologia",                                                   "BR",           FALSE,           FALSE,        "fetch",     FALSE,
    "PCE",              "PCE - Programa de Controle da Esquistossomose",                              "UF",           FALSE,           TRUE,         "fetch",     FALSE,
    "IBGE",             "Base Populacional - IBGE",                                                   "BR",           FALSE,           FALSE,        "fetch",     FALSE,
    "DATASUS",          "Aplicativos - TABWIN/TABNET",                                                "BR",           FALSE,           FALSE,        "ftp_only",  TRUE,
    "BASE_TERRITORIAL", "Base Territorial - Mapas e conversoes para tabulacao",                       "BR",           FALSE,           FALSE,        "territory", TRUE
  )
}

#' Internal DATASUS modality catalog
#'
#' @return A tibble.
#' @keywords internal
.datasus_modalities_tbl <- function() {
  tibble::tribble(
    ~modality_code, ~modality,       ~description,                              ~subdir,
    0L,             "auxiliary",      "Arquivos auxiliares para tabulacao",       "Auxiliar",
    1L,             "data",          "Dados",                                   "Dados",
    2L,             "documentation", "Documentacao",                            "DOCS",
    3L,             "programs",      "Programas",                               "Programas",
    4L,             "territorial",   "Bases territoriais",                      "Base_Territorial",
    5L,             "maps",          "Mapas",                                   "Mapas",
    6L,             "conversions",   "Conversoes",                              "Conversoes"
  )
}

#' Internal DATASUS program catalog
#'
#' @return A tibble.
#' @keywords internal
.datasus_programs_tbl <- function() {
  tibble::tribble(
    ~file_type, ~description,                                  ~scope,
    "TABWIN",   "TABWIN - Tabulador de dados para Windows",    "BR",
    "TABNET",   "TABNET - Tabulador de dados para internet",   "BR",
    "TABDOS",   "TABDOS - Tabulador de dados para DOS",        "BR"
  )
}

#' Internal DATASUS file type catalog
#'
#' @return A tibble.
#' @keywords internal
.datasus_file_types_tbl <- function() {
  tibble::tribble(
    ~source,            ~file_type, ~description,                                                               ~scope, ~frequency, ~availability,
    "SIHSUS",           "RD",       "RD - AIH Reduzida",                                                         "UF",   "monthly",  "current",
    "SIHSUS",           "RJ",       "RJ - AIH Rejeitadas",                                                       "UF",   "monthly",  "current",
    "SIHSUS",           "SP",       "SP - Servicos Profissionais",                                                "UF",   "monthly",  "current",
    "SIHSUS",           "ER",       "ER - AIH Rejeitadas com codigo de erro",                                     "UF",   "monthly",  "current",
    "SIASUS",           "AB",       "AB - APAC de Acompanhamento a Cirurgia Bariatrica",                          "UF",   "monthly",  "historical_current",
    "SIASUS",           "ABO",      "ABO - APAC Acompanhamento Pos Cirurgia Bariatrica",                          "UF",   "monthly",  "current",
    "SIASUS",           "ACF",      "ACF - APAC Confeccao de Fistula Arteriovenosa",                              "UF",   "monthly",  "current",
    "SIASUS",           "AD",       "AD - APAC de Laudos Diversos",                                               "UF",   "monthly",  "current",
    "SIASUS",           "AM",       "AM - APAC de Medicamentos",                                                  "UF",   "monthly",  "current",
    "SIASUS",           "AN",       "AN - APAC de Nefrologia",                                                    "UF",   "monthly",  "historical_current",
    "SIASUS",           "AQ",       "AQ - APAC de Quimioterapia",                                                 "UF",   "monthly",  "current",
    "SIASUS",           "AR",       "AR - APAC de Radioterapia",                                                  "UF",   "monthly",  "current",
    "SIASUS",           "ATD",      "ATD - APAC Tratamento Dialitico",                                            "UF",   "monthly",  "current",
    "SIASUS",           "PA",       "PA - Producao Ambulatorial",                                                 "UF",   "monthly",  "historical_current",
    "SIASUS",           "PS",       "PS - Psicossocial",                                                          "UF",   "monthly",  "historical_current",
    "SIASUS",           "SAD",      "SAD - Atencao Domiciliar",                                                   "UF",   "monthly",  "current",
    "SIM",              "DO",       "DO - Declaracoes de Obito",                                                   "TT",   "yearly",   "current_prelim",
    "SIM",              "DOFET",    "DOFET - Declaracoes de Obitos fetais",                                        "BR",   "yearly",   "current_prelim",
    "SIM",              "DOEXT",    "DOEXT - Declaracoes de Obitos por causas externas",                           "BR",   "yearly",   "current_prelim",
    "SIM",              "DOINF",    "DOINF - Declaracoes de Obitos infantis",                                      "BR",   "yearly",   "current_prelim",
    "SIM",              "DOMAT",    "DOMAT - Declaracoes de Obitos maternos",                                      "BR",   "yearly",   "current_prelim",
    "SINASC",           "DN",       "DN - Declaracoes de nascidos vivos",                                          "TT",   "yearly",   "current_prelim",
    "SINASC",           "DNEX",     "DNEX - Declaracoes de nascidos vivos residentes no exterior",                 "BR",   "yearly",   "current",
    "SISPRENATAL",      "PN",       "PN - Pre-Natal",                                                              "UF",   "monthly",  "historical",
    "CIHA",             "CIHA",     "CIHA - Comunicacao de Internacao Hospitalar e Ambulatorial",                  "UF",   "monthly",  "current",
    "CIH",              "CR",       "CR - Comunicacao de Internacao Hospitalar",                                    "UF",   "monthly",  "current",
    "CNES",             "LT",       "LT - Leitos",                                                                 "UF",   "monthly",  "current",
    "CNES",             "ST",       "ST - Estabelecimentos",                                                        "UF",   "monthly",  "current",
    "CNES",             "DC",       "DC - Dados Complementares",                                                    "UF",   "monthly",  "current",
    "CNES",             "EQ",       "EQ - Equipamentos",                                                            "UF",   "monthly",  "current",
    "CNES",             "SR",       "SR - Servico Especializado",                                                   "UF",   "monthly",  "current",
    "CNES",             "HB",       "HB - Habilitacao",                                                             "UF",   "monthly",  "current",
    "CNES",             "PF",       "PF - Profissional",                                                            "UF",   "monthly",  "current",
    "CNES",             "EP",       "EP - Equipes",                                                                 "UF",   "monthly",  "current",
    "CNES",             "RC",       "RC - Regra Contratual",                                                        "UF",   "monthly",  "current",
    "CNES",             "IN",       "IN - Incentivos",                                                              "UF",   "monthly",  "current",
    "CNES",             "EE",       "EE - Estabelecimento de Ensino",                                               "UF",   "monthly",  "current",
    "CNES",             "EF",       "EF - Estabelecimento Filantropico",                                            "UF",   "monthly",  "current",
    "CNES",             "GM",       "GM - Gestao e Metas",                                                          "UF",   "monthly",  "current",
    "SINAN",            "DENG",     "DENG - Dengue",                                                                "BR",   "yearly",   "current",
    "SINAN",            "CHIK",     "CHIK - Febre de Chikungunya",                                                  "BR",   "yearly",   "current",
    "SINAN",            "ZIKA",     "ZIKA - Zika Virus",                                                            "BR",   "yearly",   "current",
    "SINAN",            "MALA",     "MALA - Malaria",                                                               "BR",   "yearly",   "current",
    "SINAN",            "CHAG",     "CHAG - Doenca de Chagas",                                                      "BR",   "yearly",   "current",
    "SINAN",            "HANS",     "HANS - Hanseniase (Lepra)",                                                    "BR",   "yearly",   "current",
    "SINAN",            "TUBE",     "TUBE - Tuberculose",                                                           "BR",   "yearly",   "current",
    "SINAN",            "LEIV",     "LEIV - Leishmaniose Visceral",                                                 "BR",   "yearly",   "current",
    "SINAN",            "LTAN",     "LTAN - Leishmaniose Tegumentar",                                               "BR",   "yearly",   "current",
    "SINAN",            "LEPT",     "LEPT - Leptospirose",                                                          "BR",   "yearly",   "current",
    "SINAN",            "HANT",     "HANT - Hantavirose",                                                           "BR",   "yearly",   "current",
    "SINAN",            "MENI",     "MENI - Meningite",                                                             "BR",   "yearly",   "current",
    "SINAN",            "VIOL",     "VIOL - Violencia Interpessoal/Autoprovocada",                                  "BR",   "yearly",   "current",
    "SINAN",            "IEXO",     "IEXO - Intoxicacao Exogena",                                                   "BR",   "yearly",   "current",
    "SINAN",            "ANIM",     "ANIM - Acidente por Animais Peconhentos",                                      "BR",   "yearly",   "current",
    "SINAN",            "COQU",     "COQU - Coqueluche",                                                            "BR",   "yearly",   "current",
    "SINAN",            "TETA",     "TETA - Tetano Acidental",                                                      "BR",   "yearly",   "current",
    "SINAN",            "DIFT",     "DIFT - Difteria",                                                              "BR",   "yearly",   "current",
    "SINAN",            "RAIV",     "RAIV - Raiva Humana",                                                          "BR",   "yearly",   "current",
    "ESUSNOTIFICA",     "DCCR",     "DCCR - Doenca de Chagas Cronica",                                              "BR",   "yearly",   "current",
    "ESUSNOTIFICA_P",   "DCCR",     "DCCR - Doenca de Chagas Cronica",                                              "BR",   "yearly",   "current",
    "RESP",             "RESP",     "RESP - Notificacoes de casos suspeitos de SCZ",                                "UF",   "yearly",   "current",
    "PO",               "PO",       "PO - Painel de Oncologia",                                                     "BR",   "yearly",   "current",
    "PCE",              "PCE",      "PCE - Programa de Controle da Esquistossomose",                                "UF",   "yearly",   "current",
    "IBGE",             "POP",      "POP - Censo e Estimativas",                                                    "BR",   "yearly",   "current",
    "IBGE",             "POPS",     "POPS - Estimativas por sexo e idade",                                          "BR",   "yearly",   "current",
    "IBGE",             "POPT",     "POPT - Estimativas TCU",                                                       "BR",   "yearly",   "current",
    "DATASUS",          "TABWIN",   "TABWIN - Tabulador de dados para Windows",                                     "BR",   "static",   "current",
    "DATASUS",          "TABNET",   "TABNET - Tabulador de dados para internet",                                    "BR",   "static",   "current",
    "DATASUS",          "TABDOS",   "TABDOS - Tabulador de dados para DOS",                                         "BR",   "static",   "current",
    "BASE_TERRITORIAL", "TER",      "Bases Territoriais",                                                           "BR",   "static",   "current",
    "BASE_TERRITORIAL", "MAP",      "Bases Mapas",                                                                  "BR",   "static",   "current",
    "BASE_TERRITORIAL", "CNV",      "Conversoes",                                                                   "BR",   "static",   "current"
  )
}

#' Internal path templates for DATASUS FTP
#'
#' @return A tibble.
#' @keywords internal
.datasus_path_templates_tbl <- function() {
  tibble::tribble(
    ~source,    ~file_type,      ~period,       ~path,
    "SIHSUS",   NA_character_,   "historical",  "ftp://ftp.datasus.gov.br/dissemin/publicos/SIHSUS/199201_200712/Dados/",
    "SIHSUS",   NA_character_,   "current",     "ftp://ftp.datasus.gov.br/dissemin/publicos/SIHSUS/200801_/Dados/",
    "SIASUS",   NA_character_,   "historical",  "ftp://ftp.datasus.gov.br/dissemin/publicos/SIASUS/199407_200712/Dados/",
    "SIASUS",   NA_character_,   "current",     "ftp://ftp.datasus.gov.br/dissemin/publicos/SIASUS/200801_/Dados/",
    "CNES",     "LT",            "current",     "ftp://ftp.datasus.gov.br/dissemin/publicos/CNES/200508_/Dados/LT/",
    "CNES",     "ST",            "current",     "ftp://ftp.datasus.gov.br/dissemin/publicos/CNES/200508_/Dados/ST/",
    "CNES",     "DC",            "current",     "ftp://ftp.datasus.gov.br/dissemin/publicos/CNES/200508_/Dados/DC/",
    "CNES",     "EQ",            "current",     "ftp://ftp.datasus.gov.br/dissemin/publicos/CNES/200508_/Dados/EQ/",
    "CNES",     "SR",            "current",     "ftp://ftp.datasus.gov.br/dissemin/publicos/CNES/200508_/Dados/SR/",
    "CNES",     "HB",            "current",     "ftp://ftp.datasus.gov.br/dissemin/publicos/CNES/200508_/Dados/HB/",
    "CNES",     "PF",            "current",     "ftp://ftp.datasus.gov.br/dissemin/publicos/CNES/200508_/Dados/PF/",
    "CNES",     "EP",            "current",     "ftp://ftp.datasus.gov.br/dissemin/publicos/CNES/200508_/Dados/EP/",
    "CNES",     "RC",            "current",     "ftp://ftp.datasus.gov.br/dissemin/publicos/CNES/200508_/Dados/RC/",
    "CNES",     "IN",            "current",     "ftp://ftp.datasus.gov.br/dissemin/publicos/CNES/200508_/Dados/IN/",
    "CNES",     "EE",            "current",     "ftp://ftp.datasus.gov.br/dissemin/publicos/CNES/200508_/Dados/EE/",
    "CNES",     "EF",            "current",     "ftp://ftp.datasus.gov.br/dissemin/publicos/CNES/200508_/Dados/EF/",
    "CNES",     "GM",            "current",     "ftp://ftp.datasus.gov.br/dissemin/publicos/CNES/200508_/Dados/GM/",
    "SIM",      "DO",            "current",     "ftp://ftp.datasus.gov.br/dissemin/publicos/SIM/CID10/DORES/",
    "SIM",      "DO",            "prelim",      "ftp://ftp.datasus.gov.br/dissemin/publicos/SIM/PRELIM/DORES/",
    "SIM",      "DOFET",         "current",     "ftp://ftp.datasus.gov.br/dissemin/publicos/SIM/CID10/DOFET/",
    "SIM",      "DOFET",         "prelim",      "ftp://ftp.datasus.gov.br/dissemin/publicos/SIM/PRELIM/DOFET/",
    "SIM",      "DOEXT",         "current",     "ftp://ftp.datasus.gov.br/dissemin/publicos/SIM/CID10/DOFET/",
    "SIM",      "DOEXT",         "prelim",      "ftp://ftp.datasus.gov.br/dissemin/publicos/SIM/PRELIM/DOFET/",
    "SIM",      "DOINF",         "current",     "ftp://ftp.datasus.gov.br/dissemin/publicos/SIM/CID10/DOFET/",
    "SIM",      "DOINF",         "prelim",      "ftp://ftp.datasus.gov.br/dissemin/publicos/SIM/PRELIM/DOFET/",
    "SIM",      "DOMAT",         "current",     "ftp://ftp.datasus.gov.br/dissemin/publicos/SIM/CID10/DOFET/",
    "SIM",      "DOMAT",         "prelim",      "ftp://ftp.datasus.gov.br/dissemin/publicos/SIM/PRELIM/DOFET/",
    "SINASC",   "DN",            "historical",  "ftp://ftp.datasus.gov.br/dissemin/publicos/SINASC/1994_1995/Dados/DNRES/",
    "SINASC",   "DN",            "current",     "ftp://ftp.datasus.gov.br/dissemin/publicos/SINASC/1996_/Dados/DNRES/",
    "SINASC",   "DN",            "prelim",      "ftp://ftp.datasus.gov.br/dissemin/publicos/SINASC/PRELIM/DNRES/",
    "SINASC",   "DNEX",          "current",     "ftp://ftp.datasus.gov.br/dissemin/publicos/SINASC/1996_/Dados/DNRES/",
    # --- CIH / CIHA ---
    "CIH",      NA_character_,   "current",     "ftp://ftp.datasus.gov.br/dissemin/publicos/CIH/200801_201012/Dados/",
    "CIHA",     NA_character_,   "current",     "ftp://ftp.datasus.gov.br/dissemin/publicos/CIHA/201101_/Dados/",
    # --- SISPRENATAL ---
    "SISPRENATAL", NA_character_, "historical",  "ftp://ftp.datasus.gov.br/dissemin/publicos/SISPRENATAL/201201_/Dados/",
    # --- SINAN ---
    "SINAN",    NA_character_,   "current",     "ftp://ftp.datasus.gov.br/dissemin/publicos/SINAN/DADOS/FINAIS/",
    "SINAN",    NA_character_,   "prelim",      "ftp://ftp.datasus.gov.br/dissemin/publicos/SINAN/DADOS/PRELIM/",
    "SINAN_P",  NA_character_,   "current",     "ftp://ftp.datasus.gov.br/dissemin/publicos/SINAN/DADOS/PRELIM/",
    # --- ESUSNOTIFICA ---
    "ESUSNOTIFICA",   NA_character_, "current",  "ftp://ftp.datasus.gov.br/dissemin/publicos/ESUSNOTIFICA/DADOS/FINAIS/",
    "ESUSNOTIFICA",   NA_character_, "prelim",   "ftp://ftp.datasus.gov.br/dissemin/publicos/ESUSNOTIFICA/DADOS/PRELIM/",
    "ESUSNOTIFICA_P", NA_character_, "current",  "ftp://ftp.datasus.gov.br/dissemin/publicos/ESUSNOTIFICA/DADOS/PRELIM/",
    # --- RESP / PO / PCE ---
    "RESP",     NA_character_,   "current",     "ftp://ftp.datasus.gov.br/dissemin/publicos/RESP/DADOS/",
    "PO",       NA_character_,   "current",     "ftp://ftp.datasus.gov.br/dissemin/publicos/painel_oncologia/Dados/",
    "PCE",      NA_character_,   "current",     "ftp://ftp.datasus.gov.br/dissemin/publicos/PCE/DADOS/",
    # --- IBGE ---
    "IBGE",     "POP",           "current",     "ftp://ftp.datasus.gov.br/dissemin/publicos/IBGE/POP/",
    "IBGE",     "POPS",          "current",     "ftp://ftp.datasus.gov.br/dissemin/publicos/IBGE/POPS/",
    "IBGE",     "POPT",          "current",     "ftp://ftp.datasus.gov.br/dissemin/publicos/IBGE/POPT/"
  )
}

#' Internal FTP paths for territorial and documentation resources
#'
#' @return A named list of FTP URLs.
#' @keywords internal
.datasus_extra_paths <- function() {
  list(
    territory_tables     = "ftp://ftp.datasus.gov.br/territorio/tabelas/",
    territory_conversions = "ftp://ftp.datasus.gov.br/territorio/conversoes/",
    territory_maps       = "ftp://ftp.datasus.gov.br/territorio/mapas/",
    docs_sihsus          = "ftp://ftp.datasus.gov.br/dissemin/publicos/SIHSUS/200801_/Doc/",
    docs_siasus          = "ftp://ftp.datasus.gov.br/dissemin/publicos/SIASUS/200801_/Doc/",
    docs_cnes            = "ftp://ftp.datasus.gov.br/dissemin/publicos/CNES/200508_/Doc/",
    docs_sim             = "ftp://ftp.datasus.gov.br/dissemin/publicos/SIM/CID10/DOC/",
    docs_sinasc          = "ftp://ftp.datasus.gov.br/dissemin/publicos/SINASC/1996_/Doc/"
  )
}

# ---- Public catalog helpers --------------------------------------------------

#' List DATASUS data sources
#'
#' Returns the internal catalog of DATASUS sources available in `datasusr`.
#'
#' @return A tibble with one row per source, including its code, description,
#'   default scope, and flags for monthly and UF support.
#' @export
#'
#' @examples
#' datasus_sources()
datasus_sources <- function() {
  .datasus_sources_tbl() |>
    dplyr::arrange(source)
}

#' List DATASUS modalities
#'
#' Returns the available DATASUS data modalities (data, documentation,
#' programs, etc.).
#'
#' @return A tibble.
#' @export
#'
#' @examples
#' datasus_modalities()
datasus_modalities <- function() {
  .datasus_modalities_tbl() |>
    dplyr::arrange(modality_code)
}

#' List DATASUS file types
#'
#' Returns the internal catalog of file types. Optionally filtered by source
#' and/or file type codes.
#'
#' @param source Optional character vector of source codes (e.g. `"SIHSUS"`).
#' @param file_type Optional character vector of file type codes (e.g. `"RD"`).
#'
#' @return A tibble.
#' @export
#'
#' @examples
#' datasus_file_types()
#' datasus_file_types(source = "SIHSUS")
#' datasus_file_types(source = "CNES", file_type = "ST")
datasus_file_types <- function(source = NULL, file_type = NULL) {
  out <- .datasus_file_types_tbl()

  if (!is.null(source)) {
    src_filter <- unique(toupper(as.character(source)))
    out <- dplyr::filter(out, source %in% .env$src_filter)
  }

  if (!is.null(file_type)) {
    ft_filter <- unique(toupper(as.character(file_type)))
    out <- dplyr::filter(out, file_type %in% .env$ft_filter)
  }

  out |>
    dplyr::distinct() |>
    dplyr::arrange(source, file_type)
}

#' List UF codes used by DATASUS downloads
#'
#' Returns a character vector of the 27 Brazilian state abbreviations accepted
#' by DATASUS file naming conventions.
#'
#' @return A character vector of length 27.
#' @export
#'
#' @examples
#' datasus_ufs()
datasus_ufs <- function() {
  c("AC", "AL", "AM", "AP", "BA", "CE", "DF", "ES", "GO", "MA", "MG", "MS",
    "MT", "PA", "PB", "PE", "PI", "PR", "RJ", "RN", "RO", "RR", "RS", "SC",
    "SE", "SP", "TO")
}

# ---- FTP helpers -------------------------------------------------------------

#' List files and directories from the DATASUS FTP
#'
#' Fetches a raw directory listing from a DATASUS FTP path.
#'
#' @param path FTP path or full URL. Relative paths are prefixed with the
#'   DATASUS public FTP root.
#' @param timeout Timeout in seconds (default 120).
#' @param ftp_use_epsv Logical. Passed to curl (default `FALSE`).
#' @param verbose Logical. Emit progress messages (default `TRUE`).
#'
#' @return A tibble with columns `ftp_url` and `entry`.
#' @export
#'
#' @examples
#' \dontrun{
#' datasus_ftp_ls("SIHSUS/200801_/Dados/")
#' }
datasus_ftp_ls <- function(path, timeout = 120, ftp_use_epsv = FALSE, verbose = TRUE) {
  if (!is.character(path) || length(path) != 1L || is.na(path)) {
    cli::cli_abort("{.arg path} must be a single non-missing character string.")
  }

  url <- if (stringr::str_detect(path, "^ftp://")) {
    path
  } else {
    paste0("ftp://ftp.datasus.gov.br/dissemin/publicos/", stringr::str_remove(path, "^/+"))
  }

  if (isTRUE(verbose)) {
    cli::cli_alert_info("Listing FTP directory: {.url {url}}")
  }

  handle <- curl::new_handle(
    dirlistonly = TRUE,
    ftp_use_epsv = ftp_use_epsv,
    timeout = timeout
  )
  res <- tryCatch(
    curl::curl_fetch_memory(url, handle = handle),
    error = function(e) {
      cli::cli_abort(c(
        "Could not connect to the DATASUS FTP.",
        "i" = "Check your internet connection or try again later.",
        "x" = conditionMessage(e)
      ))
    }
  )

  txt <- rawToChar(res$content)
  entries <- txt |>
    stringr::str_split("\n", simplify = FALSE) |>
    unlist(use.names = FALSE) |>
    stringr::str_trim() |>
    (\(x) x[x != ""])()

  out <- tibble::tibble(ftp_url = url, entry = entries)

  if (isTRUE(verbose)) {
    cli::cli_alert_success(
      "FTP listing complete: {format(nrow(out), big.mark = ',')} {cli::qty(nrow(out))} entr{?y/ies} found."
    )
  }

  out
}

#' Build DATASUS FTP paths from filters
#'
#' Builds candidate FTP directories for a given source and file type. For
#' SIH/SIA, the function selects historical vs. current trees by year/month.
#' For SIM and SINASC, preliminary trees are included when requested.
#'
#' @param source Source code (e.g. `"SIHSUS"`).
#' @param file_type File type code (e.g. `"RD"`).
#' @param year Integer vector of years.
#' @param month Integer vector of months.
#' @param include_prelim Logical. Include preliminary trees when available
#'   (default `TRUE`).
#'
#' @return A tibble with columns `source`, `file_type`, `period`, and `path`.
#' @export
#'
#' @examples
#' datasus_build_path(source = "SIHSUS", file_type = "RD", year = 2024, month = 1)
datasus_build_path <- function(source, file_type, year = NULL, month = NULL, include_prelim = TRUE) {
  src <- toupper(source)
  ft  <- toupper(file_type)

  paths <- .datasus_path_templates_tbl() |>
    dplyr::filter(
      source == .env$src,
      is.na(file_type) | file_type == .env$ft
    )

  if (nrow(paths) == 0L) {
    cli::cli_abort(c(
      "No FTP template registered for {.val {src}} / {.val {ft}}.",
      "i" = "Run {.fn datasus_file_types} to see the available catalog.",
      "i" = "Use {.fn datasus_ftp_ls} to navigate the FTP manually."
    ))
  }

  if (!include_prelim) {
    paths <- dplyr::filter(paths, period != "prelim")
  }

  if (src %in% c("SIHSUS", "SIASUS")) {
    if (is.null(year) || is.null(month)) {
      cli::cli_abort(c(
        "{.arg year} and {.arg month} are required for {.val {src}}.",
        "i" = "SIH and SIA files are organized by year-month on the FTP."
      ))
    }

    ym <- as.integer(year) * 100L + as.integer(month)
    use_historical <- ym <= 200712L

    paths <- if (all(use_historical)) {
      dplyr::filter(paths, period == "historical")
    } else if (all(!use_historical)) {
      dplyr::filter(paths, period == "current")
    } else {
      dplyr::filter(paths, period %in% c("historical", "current"))
    }
  }

  if (src == "SINASC" && !is.null(year)) {
    paths <- dplyr::filter(
      paths,
      (period == "historical" & .env$year <= 1995L) |
        (period == "current"    & .env$year >= 1996L) |
        (period == "prelim"     & .env$include_prelim)
    )
  }

  paths |>
    dplyr::distinct(source, file_type, period, path) |>
    dplyr::arrange(period)
}

# ---- File name generation (internal) ----------------------------------------

.datasus_format_date_token <- function(year, month = NULL,
                                       frequency = c("monthly", "yearly")) {
  frequency <- match.arg(frequency)

  if (frequency == "monthly") {
    stringr::str_c(
      stringr::str_sub(sprintf("%04d", as.integer(year)), 3, 4),
      sprintf("%02d", as.integer(month))
    )
  } else {
    sprintf("%04d", as.integer(year))
  }
}

.datasus_candidate_file_names <- function(src, ft, year = NULL, month = NULL, uf = NULL) {
  meta <- datasus_file_types(source = src, file_type = ft)

  if (nrow(meta) != 1L) {
    cli::cli_abort("Could not resolve a unique file type for {.val {src}} / {.val {ft}}.")
  }

  scope     <- meta$scope[[1]]
  frequency <- meta$frequency[[1]]
  src_code  <- meta$source[[1]]
  ft_code   <- meta$file_type[[1]]

  years  <- year  %||% integer()
  months <- month %||% integer()
  ufs    <- uf    %||% character()

  if (frequency == "monthly" && (length(years) == 0L || length(months) == 0L)) {
    cli::cli_abort(c(
      "Monthly files require both {.arg year} and {.arg month}.",
      "i" = "{.val {ft_code}} ({.val {src_code}}) is a {frequency} file type."
    ))
  }

  if (frequency == "yearly" && length(years) == 0L) {
    cli::cli_abort(c(
      "Yearly files require {.arg year}.",
      "i" = "{.val {ft_code}} ({.val {src_code}}) is a {frequency} file type."
    ))
  }

  if (scope == "UF" && length(ufs) == 0L) {
    cli::cli_abort(c(
      "UF-scoped files require {.arg uf}.",
      "i" = "Use {.fn datasus_ufs} to see valid UF codes."
    ))
  }

  if (frequency == "monthly") {
    grid <- tidyr::expand_grid(year = years, month = months)
    tokens <- purrr::map2_chr(grid$year, grid$month,
                              .datasus_format_date_token, frequency = "monthly")
  } else {
    grid <- tidyr::expand_grid(year = years)
    tokens <- purrr::map_chr(grid$year,
                             .datasus_format_date_token, frequency = "yearly")
  }

  # SIM DO: naming DOufYYYY.dbc (4-digit year in CID10 era)

  if (src_code == "SIM" && ft_code == "DO") {
    out <- tidyr::crossing(uf = ufs %||% datasus_ufs(), token = tokens) |>
      dplyr::mutate(file_name = stringr::str_c("DO", uf, token, ".dbc"))
    return(out)
  }

  # SIM DOFET/DOEXT/DOINF/DOMAT: no UF, 2-digit year (all in DOFET dir)
  if (src_code == "SIM" && ft_code %in% c("DOFET", "DOEXT", "DOINF", "DOMAT")) {
    return(tibble::tibble(
      file_name = stringr::str_c(ft_code, stringr::str_sub(tokens, 3, 4), ".dbc")
    ))
  }

  # SINASC DN: naming DNufYYYY.dbc (4-digit year)
  if (src_code == "SINASC" && ft_code == "DN") {
    out <- tidyr::crossing(uf = ufs %||% datasus_ufs(), token = tokens) |>
      dplyr::mutate(file_name = stringr::str_c("DN", uf, token, ".dbc"))
    return(out)
  }

  # UF-scoped
  if (scope == "UF") {
    if (frequency == "yearly") {
      # UF yearly: FTufYY.dbc (2-digit year, e.g. RESPPE22.dbc)
      out <- tidyr::crossing(uf = ufs, token = tokens) |>
        dplyr::mutate(file_name = stringr::str_c(ft_code, uf, stringr::str_sub(token, 3, 4), ".dbc"))
    } else {
      # UF monthly: FTufYYMM.dbc (e.g. RDPE2401.dbc)
      out <- tidyr::crossing(uf = ufs, token = tokens) |>
        dplyr::mutate(file_name = stringr::str_c(ft_code, uf, token, ".dbc"))
    }
    return(out)
  }

  # SINAN / SINAN_P / ESUSNOTIFICA: include "BR" scope code in file name
  # e.g. DENGBR23.dbc, CHIKBR23.dbc, DCCRBR23.dbc
  if (src_code %in% c("SINAN", "SINAN_P", "ESUSNOTIFICA", "ESUSNOTIFICA_P")) {
    return(tibble::tibble(
      file_name = stringr::str_c(ft_code, "BR", stringr::str_sub(tokens, 3, 4), ".dbc")
    ))
  }

  # PO (Painel de Oncologia): POBRYYYY.dbc (BR + 4-digit year)
  if (src_code == "PO") {
    return(tibble::tibble(
      file_name = stringr::str_c(ft_code, "BR", tokens, ".dbc")
    ))
  }

  # IBGE population files: use .dbf extension and include "BR" scope
  # e.g. POPBR12.dbf, POPTBR21.dbf
  if (src_code == "IBGE") {
    return(tibble::tibble(
      file_name = stringr::str_c(ft_code, "BR", stringr::str_sub(tokens, 3, 4), ".dbf")
    ))
  }

  # Other national scope (BR / TT)
  if (scope %in% c("BR", "TT")) {
    if (frequency == "monthly") {
      return(tibble::tibble(file_name = stringr::str_c(ft_code, tokens, ".dbc")))
    } else {
      return(tibble::tibble(
        file_name = stringr::str_c(ft_code, stringr::str_sub(tokens, 3, 4), ".dbc")
      ))
    }
  }

  tibble::tibble(file_name = character())
}

# ---- List available files ----------------------------------------------------

#' List available DATASUS files
#'
#' Builds candidate file names from the internal catalog and, optionally,
#' validates them against the DATASUS FTP.
#'
#' @param source Character vector of source codes.
#' @param file_type Character vector of file type codes.
#' @param year Integer vector of years.
#' @param month Integer vector of months (required for monthly sources).
#' @param uf Character vector of UF codes (required for UF-scoped sources).
#' @param include_prelim Logical. Include preliminary data trees (default `TRUE`).
#' @param check_exists Logical. Query the FTP and keep only files that exist
#'   (default `TRUE`). Setting to `FALSE` skips FTP access and returns all
#'   candidate files.
#' @param timeout Timeout in seconds for FTP requests (default 120).
#' @param ftp_use_epsv Logical. Passed to curl (default `FALSE`).
#' @param verbose Logical. Emit progress messages (default `TRUE`).
#'
#' @return A tibble with one row per file, including its FTP URL and metadata.
#' @export
#'
#' @examples
#' \dontrun{
#' datasus_list_files(
#'   source    = "SIHSUS",
#'   file_type = "RD",
#'   year      = 2024,
#'   month     = 1,
#'   uf        = c("PE", "PB")
#' )
#' }
datasus_list_files <- function(
  source,
  file_type,
  year = NULL,
  month = NULL,
  uf = NULL,
  include_prelim = TRUE,
  check_exists = TRUE,
  timeout = 120,
  ftp_use_epsv = FALSE,
  verbose = TRUE
) {
  src_input <- unique(toupper(as.character(source)))
  ft_input  <- unique(toupper(as.character(file_type)))
  uf_input  <- if (is.null(uf)) NULL else unique(toupper(as.character(uf)))

  combos <- tidyr::crossing(source = src_input, file_type = ft_input) |>
    dplyr::semi_join(.datasus_file_types_tbl(), by = c("source", "file_type"))

  if (nrow(combos) == 0L) {
    cli::cli_abort(c(
      "No valid source/file_type combinations found.",
      "i" = "Run {.fn datasus_file_types} to see the available catalog."
    ))
  }

  if (isTRUE(verbose)) {
    cli::cli_h2("Listing DATASUS files")
    cli::cli_alert_info(
      "Found {nrow(combos)} valid source/file_type combination{?s} to query."
    )
  }

  build_one <- function(src, ft) {
    meta <- datasus_file_types(source = src, file_type = ft)
    if (nrow(meta) == 0L) return(tibble::tibble())

    paths <- datasus_build_path(
      source = src, file_type = ft,
      year = year, month = month,
      include_prelim = include_prelim
    ) |>
      dplyr::select(period, path)

    names_tbl <- .datasus_candidate_file_names(
      src = src, ft = ft,
      year = year, month = month, uf = uf_input
    )

    out <- tidyr::crossing(paths, names_tbl) |>
      dplyr::mutate(
        source       = .env$src,
        file_type    = .env$ft,
        description  = meta$description[[1]],
        scope        = meta$scope[[1]],
        frequency    = meta$frequency[[1]],
        availability = meta$availability[[1]],
        url          = stringr::str_c(path, file_name)
      )

    if (!check_exists) {
      return(dplyr::mutate(out, exists = NA))
    }

    dir_entries <- purrr::map(paths$path, \(p) {
      tryCatch(
        datasus_ftp_ls(p, timeout = timeout, ftp_use_epsv = ftp_use_epsv, verbose = FALSE),
        error = function(e) tibble::tibble(ftp_url = p, entry = character())
      )
    }) |>
      purrr::list_rbind() |>
      dplyr::rename(path = ftp_url, file_name = entry)

    result <- out |>
      dplyr::left_join(
        dplyr::mutate(dir_entries, exists = TRUE),
        by = c("path", "file_name")
      ) |>
      dplyr::mutate(exists = dplyr::coalesce(exists, FALSE)) |>
      dplyr::filter(exists)

    if (nrow(result) == 0L && isTRUE(verbose)) {
      cli::cli_alert_warning(
        "No files matched for {.val {src}}/{.val {ft}} on the FTP."
      )
      cli::cli_alert_info("Directory tried: {.url {paths$path[[1]]}}")
      cli::cli_alert_info("File names tried: {.val {out$file_name}}")
      cli::cli_alert_info("Files found in directory: {.val {dir_entries$file_name}}")
    }

    result
  }

  out <- purrr::map2(combos$source, combos$file_type, build_one) |>
    purrr::list_rbind() |>
    dplyr::select(
      source, file_type, description, scope, frequency, availability,
      period, path, file_name, url,
      dplyr::any_of("exists")
    ) |>
    dplyr::distinct() |>
    dplyr::arrange(source, file_type, period, file_name)

  if (isTRUE(verbose)) {
    cli::cli_alert_success(
      "File listing complete: {format(nrow(out), big.mark = ',')} file{?s} found."
    )
  }

  out
}

# ---- Cache -------------------------------------------------------------------

#' Resolve the datasusr cache directory
#'
#' Returns the active cache directory path. Checks, in order: the `cache_dir`
#' argument, the `DATASUSR_CACHE_DIR` environment variable, the
#' `datasusr.cache_dir` option, and finally the default user cache directory.
#'
#' @param cache_dir Optional cache directory supplied by the caller.
#'
#' @return A single path string.
#' @export
#'
#' @examples
#' datasus_cache_dir()
datasus_cache_dir <- function(cache_dir = NULL) {
  cache_dir %||%
    Sys.getenv("DATASUSR_CACHE_DIR", unset = "") |>
    (\(x) if (nchar(x) == 0L) NULL else x)() %||%
    getOption("datasusr.cache_dir") %||%
    tools::R_user_dir("datasusr", which = "cache")
}

#' List cached DATASUS files
#'
#' Returns a tibble describing every file currently stored in the cache
#' directory.
#'
#' @param cache_dir Optional cache directory.
#'
#' @return A tibble with columns `path`, `file_name`, `size_bytes`,
#'   `modified_time`, and `accessed_time`.
#' @export
#'
#' @examples
#' datasus_cache_list()
datasus_cache_list <- function(cache_dir = NULL) {
  cache_dir <- datasus_cache_dir(cache_dir)

  empty <- tibble::tibble(
    path          = character(),
    file_name     = character(),
    size_bytes    = numeric(),
    modified_time = as.POSIXct(character()),
    accessed_time = as.POSIXct(character())
  )

  if (!dir.exists(cache_dir)) return(empty)

  files <- list.files(cache_dir, recursive = TRUE, full.names = TRUE,
                      all.files = FALSE, no.. = TRUE)
  files <- files[file.info(files)$isdir %in% FALSE]

  if (length(files) == 0L) return(empty)

  info <- file.info(files)

  tibble::tibble(
    path          = normalizePath(files, winslash = "/", mustWork = FALSE),
    file_name     = basename(files),
    size_bytes    = as.numeric(info$size),
    modified_time = as.POSIXct(info$mtime, origin = "1970-01-01", tz = ""),
    accessed_time = as.POSIXct(info$atime, origin = "1970-01-01", tz = "")
  ) |>
    dplyr::arrange(dplyr::desc(modified_time), file_name)
}

#' Summarise the datasusr cache
#'
#' Returns a one-row tibble summarising the current cache: directory path,
#' file count, total size, and modification time range.
#'
#' @param cache_dir Optional cache directory.
#' @param verbose Logical. Print a summary to the console (default `TRUE`).
#'
#' @return A tibble with one row.
#' @export
#'
#' @examples
#' datasus_cache_info()
datasus_cache_info <- function(cache_dir = NULL, verbose = TRUE) {
  cache_dir <- datasus_cache_dir(cache_dir)
  files <- datasus_cache_list(cache_dir)

  total <- sum(files$size_bytes, na.rm = TRUE)

  out <- tibble::tibble(
    cache_dir          = cache_dir,
    n_files            = nrow(files),
    total_size_bytes   = total,
    total_size         = format_bytes(total),
    oldest_modified    = if (nrow(files) == 0L) as.POSIXct(NA) else min(files$modified_time, na.rm = TRUE),
    newest_modified    = if (nrow(files) == 0L) as.POSIXct(NA) else max(files$modified_time, na.rm = TRUE)
  )

  if (isTRUE(verbose)) {
    cli::cli_h2("datasusr cache")
    cli::cli_alert_info("Directory: {.path {out$cache_dir}}")
    cli::cli_alert_info("Files: {format(out$n_files, big.mark = ',')}")
    cli::cli_alert_info("Total size: {out$total_size}")
  }

  out
}

#' Clear cached DATASUS files
#'
#' Removes files from the cache directory. By default all cached files are
#' removed; pass a character vector to `files` to remove specific paths.
#'
#' @param cache_dir Optional cache directory.
#' @param files Optional character vector of file paths to remove. When `NULL`,
#'   all cached files are removed.
#' @param verbose Logical. Emit progress messages (default `TRUE`).
#'
#' @return A tibble with columns `path` and `removed`.
#' @export
datasus_cache_clear <- function(cache_dir = NULL, files = NULL, verbose = TRUE) {
  cache_dir <- datasus_cache_dir(cache_dir)
  cache_tbl <- datasus_cache_list(cache_dir)

  if (nrow(cache_tbl) == 0L) {
    if (isTRUE(verbose)) cli::cli_alert_info("Cache is already empty.")
    return(tibble::tibble(path = character(), removed = logical()))
  }

  targets <- if (is.null(files)) {
    cache_tbl$path
  } else {
    intersect(
      normalizePath(files, winslash = "/", mustWork = FALSE),
      cache_tbl$path
    )
  }

  if (isTRUE(verbose)) {
    cli::cli_alert_info("Removing {length(targets)} cached file{?s}.")
  }

  removed <- vapply(targets, file.remove, logical(1))
  out <- tibble::tibble(path = targets, removed = removed)

  if (isTRUE(verbose)) {
    cli::cli_alert_success("Removed {sum(out$removed)} cached file{?s}.")
  }

  out
}

#' Prune the datasusr cache
#'
#' Selectively removes cached files based on age and/or total size. Older and
#' least-recently-accessed files are removed first.
#'
#' @param cache_dir Optional cache directory.
#' @param max_size_bytes Maximum total cache size in bytes. When exceeded, the
#'   least-recently-accessed files are removed until the cache fits.
#' @param older_than_days Age threshold in days. Files with a modification time
#'   older than this are removed.
#' @param verbose Logical. Emit progress messages (default `TRUE`).
#'
#' @return A tibble with columns `path`, `removed`, and `reason`.
#' @export
datasus_cache_prune <- function(cache_dir = NULL, max_size_bytes = NULL,
                                older_than_days = NULL, verbose = TRUE) {
  cache_dir <- datasus_cache_dir(cache_dir)
  cache_tbl <- datasus_cache_list(cache_dir)

  empty <- tibble::tibble(path = character(), removed = logical(), reason = character())

  if (nrow(cache_tbl) == 0L) {
    if (isTRUE(verbose)) cli::cli_alert_info("Cache is empty; nothing to prune.")
    return(empty)
  }

  to_remove <- tibble::tibble(path = character(), reason = character())

  # --- age-based pruning ---
  if (!is.null(older_than_days)) {
    cutoff <- Sys.time() - as.difftime(older_than_days, units = "days")
    old_files <- cache_tbl |>
      dplyr::filter(modified_time < .env$cutoff) |>
      dplyr::mutate(reason = "older_than_days") |>
      dplyr::select(path, reason)
    to_remove <- dplyr::bind_rows(to_remove, old_files)
    cache_tbl <- dplyr::filter(cache_tbl, !(path %in% old_files$path))
  }

  # --- size-based pruning ---
  if (!is.null(max_size_bytes)) {
    current_size <- sum(cache_tbl$size_bytes, na.rm = TRUE)

    if (current_size > max_size_bytes) {
      ordered <- dplyr::arrange(cache_tbl, accessed_time, modified_time)
      cumulative_kept <- rev(cumsum(rev(ordered$size_bytes)))
      drop_idx <- which(cumulative_kept > max_size_bytes)

      if (length(drop_idx) > 0L) {
        size_files <- ordered[drop_idx, , drop = FALSE] |>
          dplyr::mutate(reason = "max_size_bytes") |>
          dplyr::select(path, reason)
        to_remove <- dplyr::bind_rows(to_remove, size_files)
      }
    }
  }

  to_remove <- dplyr::distinct(to_remove, path, .keep_all = TRUE)

  if (nrow(to_remove) == 0L) {
    if (isTRUE(verbose)) cli::cli_alert_info("No cached files matched the prune rules.")
    return(empty)
  }

  if (isTRUE(verbose)) {
    cli::cli_alert_info("Pruning {nrow(to_remove)} cached file{?s}.")
  }

  removed <- vapply(to_remove$path, file.remove, logical(1))
  out <- tibble::tibble(path = to_remove$path, removed = removed, reason = to_remove$reason)

  if (isTRUE(verbose)) {
    cli::cli_alert_success("Removed {sum(out$removed)} cached file{?s}.")
  }

  out
}

# ---- Download ----------------------------------------------------------------

#' Download DATASUS files
#'
#' Downloads one or many DATASUS files. When `use_cache = TRUE`, files that
#' already exist in the cache directory are reused instead of re-downloaded.
#'
#' @param files A tibble returned by [datasus_list_files()]. When `NULL`,
#'   additional filters are forwarded to [datasus_list_files()].
#' @param ... Filters passed to [datasus_list_files()] when `files` is `NULL`.
#' @param dest_dir Optional destination directory. When `NULL` and
#'   `use_cache = TRUE`, the package cache directory is used.
#' @param overwrite Logical. Overwrite existing files (default `FALSE`).
#' @param timeout Timeout in seconds for each download (default 240).
#' @param use_cache Logical. Store and reuse downloads in the cache directory
#'   (default `TRUE`).
#' @param cache_dir Optional cache directory.
#' @param refresh Logical. Force re-download even when a cached file exists
#'   (default `FALSE`).
#' @param verbose Logical. Emit progress messages (default `TRUE`).
#'
#' @return A tibble with a `local_file` column containing the paths to the
#'   downloaded files, plus a `downloaded` flag.
#' @export
#'
#' @examples
#' \dontrun{
#' files <- datasus_list_files(
#'   source = "SIHSUS", file_type = "RD",
#'   year = 2024, month = 1, uf = "PE"
#' )
#' downloads <- datasus_download(files)
#' }
datasus_download <- function(
  files = NULL,
  ...,
  dest_dir = NULL,
  overwrite = FALSE,
  timeout = 240,
  use_cache = TRUE,
  cache_dir = NULL,
  refresh = FALSE,
  verbose = TRUE
) {
  if (is.null(files)) {
    files <- datasus_list_files(..., check_exists = TRUE, timeout = timeout, verbose = verbose)
  }

  if (!tibble::is_tibble(files)) {
    files <- tibble::as_tibble(files)
  }

  if (nrow(files) == 0L) {
    if (isTRUE(verbose)) cli::cli_alert_warning("No files to download.")
    return(dplyr::mutate(files, local_file = character(), downloaded = logical()))
  }

  cache_dir <- datasus_cache_dir(cache_dir)
  target_dir <- if (isTRUE(use_cache) && is.null(dest_dir)) cache_dir else (dest_dir %||% ".")

  if (!dir.exists(target_dir)) {
    dir.create(target_dir, recursive = TRUE, showWarnings = FALSE)
  }

  has_source_cols <- all(c("source", "file_type") %in% names(files))

  files <- files |>
    dplyr::mutate(
      source_dir = if (has_source_cols) file.path(target_dir, source, file_type) else target_dir,
      dest_file  = file.path(source_dir, file_name),
      was_cached = file.exists(dest_file)
    )

  # Create destination directories
  unique_dirs <- unique(files$source_dir)
  for (d in unique_dirs) dir.create(d, recursive = TRUE, showWarnings = FALSE)

  # Separate cached vs needs-download
  needs_download <- !files$was_cached | isTRUE(refresh) | isTRUE(overwrite) | !isTRUE(use_cache)
  n_cached <- sum(!needs_download)

  if (isTRUE(verbose)) {
    cli::cli_h1("Downloading DATASUS files")
    if (n_cached > 0L) {
      cli::cli_alert_success("{n_cached} file{?s} reused from cache.")
    }
  }

  downloaded <- rep(FALSE, nrow(files))

  if (any(needs_download)) {
    dl_urls  <- files$url[needs_download]
    dl_dests <- files$dest_file[needs_download]

    if (isTRUE(verbose)) {
      cli::cli_alert_info("Downloading {sum(needs_download)} file{?s} to {.path {target_dir}}.")
    }

    dl_result <- curl::multi_download(
      urls      = dl_urls,
      destfiles = dl_dests,
      progress  = isTRUE(verbose),
      resume    = FALSE,
      timeout   = timeout
    )

    # Report failures
    failed <- !dl_result$success
    if (any(failed)) {
      for (j in which(failed)) {
        cli::cli_alert_danger(
          "Failed: {.file {basename(dl_dests[[j]])}}: {dl_result$error[[j]]}"
        )
      }
    }

    downloaded[needs_download] <- TRUE
  }

  out <- files |>
    dplyr::mutate(
      local_file = dest_file,
      downloaded = downloaded,
      cache_dir  = if (isTRUE(use_cache)) .env$cache_dir else NA_character_
    ) |>
    dplyr::select(-source_dir, -was_cached, -dest_file)

  if (isTRUE(verbose)) {
    cli::cli_alert_success(
      "Done: {sum(downloaded)} downloaded, {n_cached} reused from cache."
    )
  }

  out
}

# ---- High-level convenience --------------------------------------------------

#' Fetch DATASUS data in one step
#'
#' A convenience wrapper that lists, downloads, and reads DATASUS files in a
#' single call. Particularly useful for interactive / exploratory work.
#'
#' @inheritParams datasus_list_files
#' @param bind Logical. When `TRUE` (the default), all files are row-bound into
#'   a single tibble. When `FALSE`, a list of tibbles is returned.
#' @param ... Additional arguments forwarded to [read_datasus_dbc()] (e.g.
#'   `select`, `col_types`, `parse_dates`).
#' @param timeout Timeout in seconds for FTP and download operations
#'   (default 240).
#' @param use_cache Logical. Reuse cached downloads (default `TRUE`).
#' @param cache_dir Optional cache directory.
#' @param verbose Logical. Emit progress messages (default `TRUE`).
#'
#' @return A tibble (when `bind = TRUE`) or a named list of tibbles.
#' @export
#'
#' @examples
#' \dontrun{
#' # Fetch SIH data for Pernambuco, Jan 2024
#' df <- datasus_fetch(
#'   source    = "SIHSUS",
#'   file_type = "RD",
#'   year      = 2024,
#'   month     = 1,
#'   uf        = "PE"
#' )
#'
#' # Fetch with column selection (snake_case names work)
#' df <- datasus_fetch(
#'   source    = "SIHSUS",
#'   file_type = "RD",
#'   year      = 2024,
#'   month     = 1:3,
#'   uf        = "PE",
#'   select    = c("uf_zi", "ano_cmpt", "munic_res", "val_tot")
#' )
#' }
datasus_fetch <- function(
  source,
  file_type,
  year = NULL,
  month = NULL,
  uf = NULL,
  ...,
  bind = TRUE,
  include_prelim = TRUE,
  timeout = 240,
  use_cache = TRUE,
  cache_dir = NULL,
  verbose = TRUE
) {
  files <- datasus_list_files(
    source = source, file_type = file_type,
    year = year, month = month, uf = uf,
    include_prelim = include_prelim,
    check_exists = TRUE,
    timeout = timeout,
    verbose = verbose
  )

  if (nrow(files) == 0L) {
    cli::cli_alert_warning("No files found for the given filters.")
    return(tibble::tibble())
  }

  downloads <- datasus_download(
    files,
    use_cache = use_cache,
    cache_dir = cache_dir,
    timeout   = timeout,
    verbose   = verbose
  )

  if (isTRUE(verbose)) {
    cli::cli_h2("Reading downloaded files")
  }

  read_args <- list(...)

  results <- purrr::map(downloads$local_file, \(f) {
    if (!file.exists(f)) {
      cli::cli_alert_warning("File not found, skipping: {.file {basename(f)}}")
      return(tibble::tibble())
    }
    do.call(read_datasus_dbc, c(list(file = f, verbose = verbose), read_args))
  })

  names(results) <- basename(downloads$local_file)

  if (isTRUE(bind)) {
    out <- purrr::list_rbind(results)
    if (isTRUE(verbose)) {
      cli::cli_alert_success(
        "Combined result: {format(nrow(out), big.mark = ',')} rows x {ncol(out)} columns."
      )
    }
    return(out)
  }

  results
}

# ---- Territorial tables ------------------------------------------------------

#' Download DATASUS territorial tables
#'
#' Downloads and reads tables from the DATASUS territorial data section.
#' The DATASUS FTP publishes a ZIP archive per year containing reference
#' tables for municipalities, health regions, and other geographic
#' divisions used by SUS, in CSV, DBF, and TXT formats.
#'
#' @param table Name of the table to read. Common values:
#'   `"tb_municip"` (municipalities), `"tb_uf"` (states),
#'   `"tb_regsaud"` (health regions), `"tb_macsaud"` (macro health regions),
#'   `"tb_regiao"` (geographic regions), `"tb_micibge"` (IBGE micro-regions),
#'   `"tb_regmetr"` (metropolitan regions), `"tb_dsei"` (indigenous health
#'   districts). Relationship tables start with `"rl_"` (e.g.
#'   `"rl_municip_regsaud"`).
#' @param year Year of the territorial table. Defaults to the current year.
#'   Use `datasus_ftp_ls("ftp://ftp.datasus.gov.br/territorio/tabelas/")`
#'   to see available years.
#' @param format File format to extract from the ZIP: `"csv"` (default) or
#'   `"dbf"`.
#' @param cache_dir Optional cache directory.
#' @param verbose Logical. Emit progress messages (default `TRUE`).
#'
#' @return A tibble with column names in snake_case.
#' @export
#'
#' @examples
#' \dontrun{
#' # Municipalities
#' municipios <- datasus_get_territory("tb_municip")
#'
#' # Health regions
#' regioes <- datasus_get_territory("tb_regsaud")
#'
#' # States
#' ufs <- datasus_get_territory("tb_uf")
#'
#' # Specific year
#' municipios_2023 <- datasus_get_territory("tb_municip", year = 2023)
#'
#' # List available years
#' datasus_ftp_ls("ftp://ftp.datasus.gov.br/territorio/tabelas/")
#' }
datasus_get_territory <- function(table = "tb_municip", year = NULL,
                                  format = "csv", cache_dir = NULL,
                                  verbose = TRUE) {
  fmt <- match.arg(format, c("csv", "dbf"))
  yr <- year %||% as.integer(format(Sys.Date(), "%Y"))
  base_url <- paste0("ftp://ftp.datasus.gov.br/territorio/tabelas/", yr, "/")

  cache_dir <- datasus_cache_dir(cache_dir)
  dest_dir <- file.path(cache_dir, "territory", yr)
  dir.create(dest_dir, recursive = TRUE, showWarnings = FALSE)

  target_file <- file.path(dest_dir, paste0(table, ".", fmt))

  if (file.exists(target_file)) {
    if (isTRUE(verbose)) {
      cli::cli_alert_success("Using cached {.file {paste0(table, '.', fmt)}} ({yr}).")
    }
  } else {
    if (isTRUE(verbose)) {
      cli::cli_alert_info("Looking for territorial ZIP in {.url {base_url}}")
    }

    dir_listing <- tryCatch(
      datasus_ftp_ls(base_url, verbose = FALSE),
      error = function(e) {
        cli::cli_abort(c(
          "Could not list territorial tables for year {yr}.",
          "i" = "Check available years: {.code datasus_ftp_ls(\"ftp://ftp.datasus.gov.br/territorio/tabelas/\")}",
          "x" = conditionMessage(e)
        ))
      }
    )

    zip_entries <- dir_listing$entry[grepl("\\.zip$", dir_listing$entry, ignore.case = TRUE)]

    if (length(zip_entries) == 0L) {
      cli::cli_abort(c(
        "No ZIP file found in the {yr} territorial directory.",
        "i" = "Available entries: {.val {dir_listing$entry}}"
      ))
    }

    zip_name <- zip_entries[[length(zip_entries)]]
    zip_url <- paste0(base_url, utils::URLencode(zip_name))
    zip_dest <- file.path(dest_dir, zip_name)

    if (!file.exists(zip_dest)) {
      if (isTRUE(verbose)) {
        cli::cli_alert_info("Downloading {.file {zip_name}}")
      }
      tryCatch(
        curl::curl_download(zip_url, destfile = zip_dest, quiet = !verbose,
                            handle = curl::new_handle(timeout = 120)),
        error = function(e) {
          cli::cli_abort(c(
            "Failed to download {.file {zip_name}}.",
            "x" = conditionMessage(e)
          ))
        }
      )
    }

    zip_contents <- utils::unzip(zip_dest, list = TRUE)$Name
    target_in_zip <- zip_contents[grepl(paste0("\\b", table, "\\.", fmt, "$"),
                                        zip_contents, ignore.case = TRUE)]

    if (length(target_in_zip) == 0L) {
      available <- unique(gsub("\\.(csv|dbf|txt|xml)$", "", basename(zip_contents),
                               ignore.case = TRUE))
      available <- sort(unique(available[!grepl("_layout$", available)]))
      cli::cli_abort(c(
        "Table {.val {table}} not found in the ZIP ({.file {zip_name}}).",
        "i" = "Available tables: {.val {available}}"
      ))
    }

    utils::unzip(zip_dest, files = target_in_zip, exdir = dest_dir,
                 junkpaths = TRUE, overwrite = TRUE)

    if (isTRUE(verbose)) {
      cli::cli_alert_success("Extracted {.file {paste0(table, '.', fmt)}} from {.file {zip_name}}.")
    }
  }

  if (fmt == "csv") {
    # Try semicolon first (Brazilian standard), fall back to comma
    out <- utils::read.csv2(target_file, fileEncoding = "latin1",
                            stringsAsFactors = FALSE, check.names = FALSE)
    if (ncol(out) <= 1L) {
      out <- utils::read.csv(target_file, fileEncoding = "latin1",
                             stringsAsFactors = FALSE, check.names = FALSE)
    }
    out <- tibble::as_tibble(out)
    names(out) <- tolower(names(out))
  } else {
    out <- read_datasus_dbc(target_file, encoding = "latin1", verbose = FALSE)
  }

  if (isTRUE(verbose)) {
    cli::cli_alert_success(
      "Loaded {.val {table}} ({yr}): {format(nrow(out), big.mark = ',')} rows x {ncol(out)} columns."
    )
  }

  out
}

# ---- Documentation paths ----------------------------------------------------

#' Get FTP URLs for DATASUS documentation
#'
#' Returns the FTP URLs where documentation files (layouts, data dictionaries)
#' for each source system can be found. Use [datasus_ftp_ls()] to list the
#' actual files at each URL.
#'
#' @param source Optional source code to filter (e.g. `"SIHSUS"`). When
#'   `NULL`, all known documentation paths are returned.
#'
#' @return A tibble with columns `source` and `docs_url`.
#' @export
#'
#' @examples
#' datasus_docs_url()
#' datasus_docs_url("CNES")
#'
#' \dontrun{
#' # List documentation files for CNES
#' docs <- datasus_docs_url("CNES")
#' datasus_ftp_ls(docs$docs_url[[1]])
#' }
datasus_docs_url <- function(source = NULL) {
  paths <- .datasus_extra_paths()
  doc_entries <- paths[grepl("^docs_", names(paths))]

  out <- tibble::tibble(
    source   = toupper(gsub("^docs_", "", names(doc_entries))),
    docs_url = unlist(doc_entries, use.names = FALSE)
  )

  if (!is.null(source)) {
    src_filter <- toupper(source)
    out <- dplyr::filter(out, source %in% .env$src_filter)
  }

  out
}
