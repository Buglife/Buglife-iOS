//
//  LIFELocalizedStringProvider.m
//  Copyright (C) 2017 Buglife, Inc.
//  
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//       http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//

#import "LIFELocalizedStringProvider.h"

typedef NS_OPTIONS(NSUInteger, LIFELanguage) {
    LIFELanguageEnglish,
    LIFELanguageFrench,
    LIFELanguageDutch,
    LIFELanguageSpanish,
    LIFELanguageGerman,
    LIFELanguageChineseSimplified,
    LIFELanguageJapanese,
    LIFELanguageKorean,
    LIFELanguageRussian,
    LIFELanguageVietnamese,
    LIFELanguageHebrew,
    LIFELanguagePolish,
    LIFELanguageSwedish,
    LIFELanguageItalian,
    LIFELanguagePortuguese,
    LIFELanguageArabic
};

@interface LIFELocalizedStringProvider ()

@property (nonatomic) LIFELanguage preferredLanguage;

@end

@implementation LIFELocalizedStringProvider

+ (instancetype)sharedInstance
{
    static LIFELocalizedStringProvider *gSharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gSharedInstance = [[self alloc] init];
        gSharedInstance.preferredLanguage = [self _getPreferredLanguage];
    });
    return gSharedInstance;
}

+ (LIFELanguage)_getPreferredLanguage
{
    LIFELanguage result = LIFELanguageEnglish;
 
    // Go through the user's preferred language, stopping
    // only when we encounter a language we support.
    for (NSString *language in [NSLocale preferredLanguages]) {
        NSString *languagePrefix = [language substringToIndex:2];
        
        NSDictionary *languagePrefixes = @{
                                           @"en" : @(LIFELanguageEnglish),
                                           @"fr" : @(LIFELanguageFrench),
                                           @"nl" : @(LIFELanguageDutch),
                                           @"es" : @(LIFELanguageSpanish),
                                           @"de" : @(LIFELanguageGerman),
                                           @"zh" : @(LIFELanguageChineseSimplified),
                                           @"ja" : @(LIFELanguageJapanese),
                                           @"ko" : @(LIFELanguageKorean),
                                           @"ru" : @(LIFELanguageRussian),
                                           @"vi" : @(LIFELanguageVietnamese),
                                           @"he" : @(LIFELanguageHebrew),
                                           @"pl" : @(LIFELanguagePolish),
                                           @"sv" : @(LIFELanguageSwedish),
                                           @"it" : @(LIFELanguageItalian),
                                           @"pt" : @(LIFELanguagePortuguese),
                                           @"ar" : @(LIFELanguageArabic)
                                           };
        
        NSNumber *languageNumber = languagePrefixes[languagePrefix];
        
        if (languageNumber != nil) {
            result = languageNumber.unsignedIntegerValue;
            break;
        }
    }
    
    return result;
}

- (NSString *)stringForKey:(NSString *)key
{
    switch (self.preferredLanguage) {
        case LIFELanguageFrench:
            return [self _frenchStringForKey:key];
            break;
        case LIFELanguageDutch:
            return [self _dutchStringForKey:key];
            break;
        case LIFELanguageSpanish:
            return [self _spanishStringForKey:key];
            break;
        case LIFELanguageGerman:
            return [self _germanStringForKey:key];
            break;
        case LIFELanguageChineseSimplified:
            return [self _chineseSimplifiedStringForKey:key];
            break;
        case LIFELanguageJapanese:
            return [self _japaneseStringForKey:key];
            break;
        case LIFELanguageKorean:
            return [self _koreanStringForKey:key];
            break;
        case LIFELanguageRussian:
            return [self _russianStringForKey:key];
            break;
        case LIFELanguageVietnamese:
            return [self _vietnameseStringForKey:key];
            break;
        case LIFELanguageHebrew:
            return [self _hebrewStringForKey:key];
            break;
        case LIFELanguagePolish:
            return [self _polishStringForKey:key];
            break;
        case LIFELanguageSwedish:
            return [self _swedishStringForKey:key];
            break;
        case LIFELanguageItalian:
            return [self _italianStringForKey:key];
            break;
        case LIFELanguagePortuguese:
            return [self _portugueseStringForKey:key];
            break;
        case LIFELanguageArabic:
            return [self _arabicStringForKey:key];
            break;
        case LIFELanguageEnglish:
            return key;
            break;
    }
    
    return key; // Compiler should warn if I'm missing a case, but just to be safe
}

- (BOOL)isEnglish
{
    return _preferredLanguage == LIFELanguageEnglish;
}

#pragma mark - French

- (NSString *)_frenchStringForKey:(NSString *)key
{
    static NSDictionary *strings;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        strings = @{
                    LIFEStringKey_Cancel : @"Annuler",
                    LIFEStringKey_OK : @"OK",
                    LIFEStringKey_Done : @"OK",
                    LIFEStringKey_Next : @"Suivant",
                    LIFEStringKey_ReportABug : @"Envoyer un avis",
                    LIFEStringKey_Delete : @"Supprimer",
                    LIFEStringKey_DeleteArrow : @"Supprimer la flèche",
                    LIFEStringKey_DeleteBlur : @"Supprimer le flou",
                    LIFEStringKey_DeleteLoupe : @"Supprimer loupe",
                    LIFEStringKey_Report : @"Avis",
                    LIFEStringKey_UserEmailInputFieldTitle : @"Votre e-mail",
                    LIFEStringKey_SummaryInputFieldTitle : @"Avis",
                    LIFEStringKey_SummaryInputFieldDetailedTitle : @"Qu'est-il arrivé?",
                    LIFEStringKey_SummaryInputFieldAccessibilityHint : @"Le texte saisi ici est présenté avec le rapport de bogue.",
                    LIFEStringKey_SummaryInputFieldAccessibilityDetailedHint : @"Le texte saisi ici est envoyé avec votre avis.",
                    LIFEStringKey_StepsToReproduce : @"Procédure pour reproduire",
                    LIFEStringKey_ExpectedResults : @"Résultats attendus",
                    LIFEStringKey_ExpectedResultsPlaceholder : @"Décrivez ce que vous vous attendiez à arriver.",
                    LIFEStringKey_ActualResults : @"Résultats actuels",
                    LIFEStringKey_ActualResultsPlaceholder : @"Décrivez ce qui est arrivé.",
                    LIFEStringKey_PoweredByBuglife : @"Propulsé par Buglife",
                    LIFEStringKey_HideUntilNextLaunch : @"Hide jusqu'au prochain lancement",
                    LIFEStringKey_DontAskUntilNextLaunch : @"Ne demandez pas jusqu'au prochain lancement",
                    LIFEStringKey_HelpUsMakeXYZBetter : @"Aidez-nous à %@ mieux!",
                    LIFEStringKey_HelpUsMakeThisAppBetter : @"Aidez-nous à améliorer cette application!",
                    LIFEStringKey_ThanksForFilingABug : @"Merci d'avoir envoyé votre avis!",
                    LIFEStringKey_AttachPhoto : @"Joindre une photo",
                    LIFEStringKey_Arrow : @"Flèche",
                    LIFEStringKey_ArrowAccessibilityValue : @"Tête pointe de %.0f pixels de haut et %.0f pixels de la gauche",
                    LIFEStringKey_Blur : @"Flou",
                    LIFEStringKey_Loupe : @"Loupe",
                    LIFEStringKey_LoupeAccessibilityValue : @"Centré au pixel de coordonnées %.0f par %.0f, et est de %.0f pixels de large par %.0f pixels de haut",
                    LIFEStringKey_Component : @"Composant",
                    LIFEStringKey_DiscardReportAlertTitle : @"Supprimer cet avis?",
                    LIFEStringKey_DiscardReportAlertMessage : @"Toutes les données de ce rapport seront supprimées... Mais vous pourrez toujours envoyer un autre avis plus tard.",
                    LIFEStringKey_DiscardReportAlertConfirm : @"Jeter",
                    LIFEStringKey_DiscardReportAlertCancel : @"Annuler",
                    LIFEStringKey_SummaryInputFieldPlaceholder : @"Avis",
                    LIFEStringKey_SummaryInputFieldDetailedPlaceholder : @"Veuillez fournir un résumé de votre rapport.",
                    LIFEStringKey_Attachments : @"Pièces jointes",
                    LIFEStringKey_GenericAlertTitle : @"Oups!",
                    LIFEStringKey_InvalidEmailAlertMessage : @"%@ n'est pas une adresse e-mail valide.",
                    LIFEStringKey_ReportSubmissionErrorAlertTitle : @"Échec de l'envoi de votre avis",
                    LIFEStringKey_ReportSubmissionErrorAlertMessage : @"Ceci peut être dû à une mauvaise qualité de la connexion réseau. Veuillez réessayer.",
                    
                    LIFEStringKey_ArrowToolLabel : @"Flèche",
                    LIFEStringKey_LoupeToolLabel : @"Zoomer",
                    LIFEStringKey_BlurToolLabel : @"Flou",
                    LIFEStringKey_ReportABugWithScreenRecording : @"Envoyer un avis avec cette capture vidéo?",
                    };
    });
    
    NSString *result = strings[key];
    
    if (result == nil) {
        result = key;
    }
    
    return result;
}

#pragma mark - Dutch

- (NSString *)_dutchStringForKey:(NSString *)key
{
    static NSDictionary *strings;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        strings = @{
                    LIFEStringKey_Cancel : @"Annuleer",
                    LIFEStringKey_OK : @"OK",
                    LIFEStringKey_Done : @"Gedaan",
                    LIFEStringKey_Next : @"Volgende",
                    LIFEStringKey_ReportABug : @"Feedback versturen",
                    LIFEStringKey_Report : @"Feedback",
                    LIFEStringKey_UserEmailInputFieldTitle : @"Jouw email",
                    LIFEStringKey_SummaryInputFieldTitle : @"Feedback",
                    LIFEStringKey_SummaryInputFieldDetailedTitle : @"Wat is er gebeurd?",
                    LIFEStringKey_SummaryInputFieldPlaceholder : @"Feedback",
                    LIFEStringKey_SummaryInputFieldDetailedPlaceholder : @"Bij het bug rapport",
                    LIFEStringKey_StepsToReproduce : @"Stappen om te reproduceren",
                    LIFEStringKey_ExpectedResults : @"Verwachte resultaten",
                    LIFEStringKey_ExpectedResultsPlaceholder : @"Beschrijf wat je dacht dat er zou gebeuren",
                    LIFEStringKey_ActualResults : @"De daadwerkelijke resultaten",
                    LIFEStringKey_ActualResultsPlaceholder : @"Beschrijf wat er werkelijk is gebeurd.",
                    LIFEStringKey_PoweredByBuglife : @"Powered by Buglife",
                    LIFEStringKey_HideUntilNextLaunch : @"Verbergen tot volgende keer opstarten",
                    LIFEStringKey_DontAskUntilNextLaunch : @"Vraag niet tot volgende keer opstarten",
                    LIFEStringKey_HelpUsMakeXYZBetter : @"Help ons om %@ beter te maken!",
                    LIFEStringKey_HelpUsMakeThisAppBetter : @"Help ons deze app beter te maken!",
                    LIFEStringKey_ThanksForFilingABug : @"Bedankt dat je ons feedback hebt gestuurd!",
                    LIFEStringKey_AttachPhoto : @"Bevestig een foto",
                    LIFEStringKey_Arrow : @"Pijl",
                    LIFEStringKey_Blur : @"Vervaag",
                    LIFEStringKey_Loupe : @"Vergrootglas",
                    LIFEStringKey_LoupeAccessibilityValue : @"Gecentreerd op pixel coördinaten %.0f bij %.0f en %.0f pixels breed en %.0f pixels hoog",
                    LIFEStringKey_ArrowAccessibilityValue : @"Kop wijst %.0f pixels van de bovenkant en %.0f pixels van links",
                    LIFEStringKey_Delete : @"Verwijder",
                    LIFEStringKey_DeleteArrow : @"Verwijder pijl",
                    LIFEStringKey_DeleteBlur : @"Verwijder blur",
                    LIFEStringKey_DeleteLoupe : @"Verwijder vergrootglas",
                    LIFEStringKey_DiscardReportAlertTitle : @"Deze feedback negeren?",
                    LIFEStringKey_DiscardReportAlertMessage : @"Alle gegevens voor dit rapport worden genegeerd... Maar je kunt altijd later nog feedback geven!",
                    LIFEStringKey_DiscardReportAlertConfirm : @"Weggooien",
                    LIFEStringKey_DiscardReportAlertCancel : @"Annuleer",
                    LIFEStringKey_SummaryInputFieldPlaceholder : @"Voer een samenvatting van je rapport in.",
                    LIFEStringKey_Attachments : @"Bijlagen",
                    LIFEStringKey_GenericAlertTitle : @"Oeps!",
                    LIFEStringKey_InvalidEmailAlertMessage : @"%@ is geen geldig e-mailadres.",
                    LIFEStringKey_ReportSubmissionErrorAlertTitle : @"We konden je feedback niet versturen.",
                    LIFEStringKey_ReportSubmissionErrorAlertMessage : @"Dit kan het gevolg zijn van een slechte netwerkverbinding. Probeer het opnieuw.",
                    
                    LIFEStringKey_ArrowToolLabel : @"Aanwijzen",
                    LIFEStringKey_LoupeToolLabel : @"In-/uitzoomen",
                    LIFEStringKey_BlurToolLabel : @"Onscherp",
                    LIFEStringKey_SummaryInputFieldAccessibilityHint : @"De tekst die hier wordt ingevoerd, wordt meegestuurd met je feedback.",
                    LIFEStringKey_ReportABugWithScreenRecording : @"Feedback versturen met die schermopname?",
                    };
    });
    
    NSString *result = strings[key];
    
    if (result == nil) {
        result = key;
    }
    
    return result;
}

#pragma mark - Spanish

- (NSString *)_spanishStringForKey:(NSString *)key
{
    static NSDictionary *strings;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        strings = @{
                    LIFEStringKey_Cancel : @"Cancelar",
                    LIFEStringKey_OK : @"OK",
                    LIFEStringKey_Done : @"Hecho",
                    LIFEStringKey_Next : @"Siguiente",
                    LIFEStringKey_ReportABug : @"Reportar un error",
                    
                    LIFEStringKey_Report : @"¿Qué ocurrió?",
                    LIFEStringKey_UserEmailInputFieldTitle : @"Tu correo electrónico",
                    LIFEStringKey_SummaryInputFieldTitle : @"¿Qué ocurrió?",
                    LIFEStringKey_SummaryInputFieldPlaceholder : @"El texto introducido aquí se presenta con el informe de error.",
                    LIFEStringKey_StepsToReproduce : @"Pasos para reproducir",
                    LIFEStringKey_ExpectedResults : @"Resultados Esperados",
                    LIFEStringKey_ExpectedResultsPlaceholder : @"Describe lo que esperabas que ocurriera",
                    LIFEStringKey_ActualResults : @"Resultado",
                    LIFEStringKey_ActualResultsPlaceholder : @"Describir lo que realmente ocurrió.",
                    LIFEStringKey_PoweredByBuglife : @"Desarrollado por Buglife",
                    
                    LIFEStringKey_HideUntilNextLaunch : @"Ocultar hasta la próxima sesión",
                    LIFEStringKey_DontAskUntilNextLaunch : @"No preguntar hasta la próxima sesión",
                    LIFEStringKey_HelpUsMakeXYZBetter : @"Ayúdanos a hacer %@ mejor!",
                    LIFEStringKey_HelpUsMakeThisAppBetter : @"Ayúdanos",
                    LIFEStringKey_ThanksForFilingABug : @"Gracias por reportar el error!",
                    
                    LIFEStringKey_AttachPhoto : @"Adjuntar una foto",
                    LIFEStringKey_Arrow : @"Flecha",
                    LIFEStringKey_Blur : @"Difuminar",
                    LIFEStringKey_Loupe : @"Lupa",
                    
                    LIFEStringKey_LoupeAccessibilityValue : @"Centrada en coordenadas de píxeles de %.0f por %.0f, y es de %.0f píxeles de ancho por %.0f píxeles de alto",
                    LIFEStringKey_ArrowAccessibilityValue : @"La cabeza está apuntando %.0f píxeles desde la parte superior y %.0f píxeles desde la izquierda",
                    
                    LIFEStringKey_Delete : @"Eliminar",
                    LIFEStringKey_DeleteArrow : @"Eliminar la flecha",
                    LIFEStringKey_DeleteBlur : @"Eliminar la falta de definición",
                    LIFEStringKey_DeleteLoupe : @"Eliminar lupa",
                    
                    LIFEStringKey_DiscardReportAlertTitle : @"Desechar este reporte de error?",
                    LIFEStringKey_DiscardReportAlertMessage : @"De este reporte de error se descartarán... Pero siempre puedes reportar otro error!",
                    LIFEStringKey_DiscardReportAlertConfirm : @"Descartar",
                    LIFEStringKey_DiscardReportAlertCancel : @"Cancelar",
                    
                    LIFEStringKey_SummaryInputFieldPlaceholder : @"Incluye un resumen de tu informe.",
                    LIFEStringKey_Attachments : @"Archivos adjuntos",
                    LIFEStringKey_GenericAlertTitle : @"¡Vaya!",
                    LIFEStringKey_InvalidEmailAlertMessage : @"%@ no es un correo electrónico válido.",
                    LIFEStringKey_ReportSubmissionErrorAlertTitle : @"No hemos podido enviar tu informe de errores.",
                    LIFEStringKey_ReportSubmissionErrorAlertMessage : @"Esto puede deberse a problemas de conexión a Internet. Vuelve a intentarlo.",
                    };
    });
    
    NSString *result = strings[key];
    
    if (result == nil) {
        result = key;
    }
    
    return result;
}

#pragma mark - German

- (NSString *)_germanStringForKey:(NSString *)key
{
    static NSDictionary *strings;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        strings = @{
                    LIFEStringKey_Cancel : @"Abbrechen",
                    LIFEStringKey_OK : @"OK",
                    LIFEStringKey_Done : @"Fertig!",
                    LIFEStringKey_Next : @"Weiter",
                    LIFEStringKey_ReportABug : @"Feedback senden",
                    LIFEStringKey_Delete : @"Löschen",
                    LIFEStringKey_DeleteArrow : @"Pfeil löschen",
                    LIFEStringKey_DeleteBlur : @"Verpixelung löschen",
                    LIFEStringKey_DeleteLoupe : @"Lupe löschen",
                    LIFEStringKey_Report : @"Feedback",
                    LIFEStringKey_UserEmailInputFieldTitle : @"Ihre E-Mail-Adresse",
                    LIFEStringKey_SummaryInputFieldTitle : @"Feedback",
                    LIFEStringKey_SummaryInputFieldDetailedTitle : @"Was ist passiert?",
                    LIFEStringKey_SummaryInputFieldPlaceholder : @"Feedback",
                    LIFEStringKey_SummaryInputFieldDetailedPlaceholder : @"Den Text, den Sie hier eingeben, wird zusammen mit dem Fehlerbericht übermittelt.",
                    LIFEStringKey_StepsToReproduce : @"Schritte zum nachvollziehen",
                    LIFEStringKey_ExpectedResults : @"Erwartete Ergebnisse",
                    LIFEStringKey_ExpectedResultsPlaceholder : @"Beschreiben Sie was hätte passieren sollen.",
                    LIFEStringKey_ActualResults : @"Tatsächliche Ergebnisse",
                    LIFEStringKey_ActualResultsPlaceholder : @"Beschreiben Sie was tatsächlich passiert ist.",
                    LIFEStringKey_PoweredByBuglife : @"Powered by Buglife",
                    LIFEStringKey_HideUntilNextLaunch : @"Bis zum nächsten Start verbergen",
                    LIFEStringKey_DontAskUntilNextLaunch : @"Bis zum nächsten Start nicht mehr fragen",
                    LIFEStringKey_HelpUsMakeXYZBetter : @"Helfen Sie uns %@ zu verbessern!",
                    LIFEStringKey_HelpUsMakeThisAppBetter : @"Helfen Sie uns diese App zu verbessern!",
                    LIFEStringKey_ThanksForFilingABug : @"Vielen Dank für Dein Feedback!",
                    LIFEStringKey_AttachPhoto : @"Foto anhängen",
                    LIFEStringKey_Arrow : @"Pfeil",
                    LIFEStringKey_ArrowAccessibilityValue : @"Spitze zeigt auf %.0f Pixel von oben und %.0f Pixel von links",
                    LIFEStringKey_Blur : @"Verpixelung",
                    LIFEStringKey_Loupe : @"Vergrößerungslupe",
                    LIFEStringKey_LoupeAccessibilityLabel : @"Vergrößerungslupe",
                    LIFEStringKey_LoupeAccessibilityValue : @"Zentriert bei Pixel-Koordinaten %.0f mal %.0f und ist %.0f Pixel breit mal %.0f Pixel hoch",
                    LIFEStringKey_Component : @"Bestandteil",
                    LIFEStringKey_DiscardReportAlertTitle : @"Feedback verwerfen?",
                    LIFEStringKey_DiscardReportAlertMessage : @"Alle Daten für diesen Bericht werden verworfen ... Du kannst uns jedoch später immer noch Feedback geben!",
                    LIFEStringKey_DiscardReportAlertConfirm : @"Verwerfen",
                    LIFEStringKey_DiscardReportAlertCancel : @"Ignorieren",
                    LIFEStringKey_SummaryInputFieldPlaceholder : @"Erstelle bitte eine Zusammenfassung deines Berichts.",
                    LIFEStringKey_Attachments : @"Anhänge",
                    LIFEStringKey_GenericAlertTitle : @"Ups!",
                    LIFEStringKey_InvalidEmailAlertMessage : @"%@ ist keine gültige E-Mail-Adresse.",
                    LIFEStringKey_ReportSubmissionErrorAlertTitle : @"Wir konnten Dein Feedback nicht übermitteln.",
                    LIFEStringKey_ReportSubmissionErrorAlertMessage : @"Das liegt vielleicht an einer schlechten Netzwerkverbindung. Bitte versuche es erneut.",
                    
                    LIFEStringKey_ArrowToolLabel : @"Zeigen",
                    LIFEStringKey_LoupeToolLabel : @"Vergrößern",
                    LIFEStringKey_BlurToolLabel : @"Verpixelung",
                    LIFEStringKey_SummaryInputFieldAccessibilityHint : @"Der hier eingegebene Text wird mit Deinem Feedback übermittelt.",
                    LIFEStringKey_ReportABugWithScreenRecording : @"Feedback mit dieser Bildschirmaufzeichnung übermitteln?",
                    };
    });
    
    NSString *result = strings[key];
    
    if (result == nil) {
        result = key;
    }
    
    return result;
}

#pragma mark - Chinese (Simplified)

- (NSString *)_chineseSimplifiedStringForKey:(NSString *)key
{
    static NSDictionary *strings;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        strings = @{
                    LIFEStringKey_ReportABugWithScreenRecording : @"将该截屏视频作为反馈发送？",
                    
                    LIFEStringKey_Cancel : @"取消",
                    LIFEStringKey_OK : @"确定",
                    LIFEStringKey_Done : @"完成",
                    LIFEStringKey_Next : @"下一步",
                    LIFEStringKey_ReportABug : @"发送反馈",
                    
                    LIFEStringKey_ArrowToolLabel : @"目的地",
                    LIFEStringKey_LoupeToolLabel : @"缩放",
                    LIFEStringKey_BlurToolLabel : @"模糊",
                    
                    // Delete annotation
                    LIFEStringKey_Delete : @"删除",
                    LIFEStringKey_DeleteArrow : @"删除箭头",
                    LIFEStringKey_DeleteBlur : @"删除模糊",
                    LIFEStringKey_DeleteLoupe : @"删除放大镜",
                    
                    // This should be short so it can fit in a back button!
                    LIFEStringKey_Report : @"反馈",
                    LIFEStringKey_UserEmailInputFieldTitle : @"您的电子邮件地址",
                    LIFEStringKey_SummaryInputFieldTitle : @"反馈",
                    LIFEStringKey_SummaryInputFieldDetailedTitle : @"发生了什么情况？",
                    LIFEStringKey_SummaryInputFieldPlaceholder : @"反馈",
                    LIFEStringKey_SummaryInputFieldDetailedPlaceholder : @"在此处输入的文字将随 Bug 报告一同提交。",
                    LIFEStringKey_SummaryInputFieldAccessibilityHint : @"在此处输入的文字将随您的反馈一起提交。",
                    LIFEStringKey_StepsToReproduce : @"重现步骤",
                    LIFEStringKey_ExpectedResults : @"期待的结果",
                    LIFEStringKey_ExpectedResultsPlaceholder : @"描述您期待发生的情况。",
                    LIFEStringKey_ActualResults : @"实际结果",
                    LIFEStringKey_ActualResultsPlaceholder : @"描述实际发生的情况。",
                    LIFEStringKey_PoweredByBuglife : @"由 Buglife 支持",
                    
                    // Prompt
                    LIFEStringKey_HideUntilNextLaunch : @"在下次启动之前保持隐藏",
                    LIFEStringKey_DontAskUntilNextLaunch : @"在下次启动之前不再询问",
                    LIFEStringKey_HelpUsMakeXYZBetter : @"帮助我们把 %@ 做得更好！",
                    LIFEStringKey_HelpUsMakeThisAppBetter : @"帮助我们把此应用做得更好！",
                    LIFEStringKey_ThanksForFilingABug : @"感谢您向我们发送反馈！",
                    
                    // Attachments
                    LIFEStringKey_AttachPhoto : @"添加照片",
                    LIFEStringKey_Arrow : @"箭头",
                    LIFEStringKey_ArrowAccessibilityValue : @"头部所指的位置距离顶部 %.0f 像素，距离左侧 %.0f 像素",
                    LIFEStringKey_Blur : @"模糊",
                    LIFEStringKey_Loupe : @"放大镜",
                    LIFEStringKey_LoupeAccessibilityLabel : @"放大镜",
                    LIFEStringKey_LoupeAccessibilityValue : @"居中于像素坐标 %.0f 和 %.0f，宽度为 %.0f 像素，高度为 %.0f 像素",
                    LIFEStringKey_Component : @"组件",
                    
                    // Discard alert
                    LIFEStringKey_DiscardReportAlertTitle : @"舍弃这个反馈？",
                    LIFEStringKey_DiscardReportAlertMessage : @"此报告的所有数据都将被丢弃...但是您以后可以随时报告反馈！",
                    LIFEStringKey_DiscardReportAlertConfirm : @"丢弃",
                    LIFEStringKey_DiscardReportAlertCancel : @"取消",
                    
                    LIFEStringKey_SummaryInputFieldPlaceholder : @"请提供报告摘要。",
                    LIFEStringKey_Attachments : @"附件",
                    LIFEStringKey_GenericAlertTitle : @"糟糕！",
                    LIFEStringKey_InvalidEmailAlertMessage : @"%@ 不是一个有效的电子邮件地址。",
                    LIFEStringKey_ReportSubmissionErrorAlertTitle : @"我们无法提交您的反馈。",
                    LIFEStringKey_ReportSubmissionErrorAlertMessage : @"这可能是由于网络连接较差所致，请重试。",
                    };
    });
    
    NSString *result = strings[key];
    
    if (result == nil) {
        result = key;
    }
    
    return result;
}

#pragma mark - Japanese

- (NSString *)_japaneseStringForKey:(NSString *)key
{
    static NSDictionary *strings;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        strings = @{
                    LIFEStringKey_Cancel : @"キャンセル",
                    LIFEStringKey_OK : @"ＯＫ",
                    LIFEStringKey_Done : @"終了",
                    LIFEStringKey_Next : @"次",
                    LIFEStringKey_ReportABug : @"フィードバックを送信",
                    LIFEStringKey_Delete : @"削除",
                    LIFEStringKey_DeleteArrow : @"矢印を削除",
                    LIFEStringKey_DeleteBlur : @"ぼかしを削除",
                    LIFEStringKey_DeleteLoupe : @"虫眼鏡を削除",
                    LIFEStringKey_Report : @"フィードバック",
                    LIFEStringKey_UserEmailInputFieldTitle : @"メールアドレス",
                    LIFEStringKey_SummaryInputFieldTitle : @"フィードバック",
                    LIFEStringKey_SummaryInputFieldDetailedTitle : @"どうしましたか？",
                    LIFEStringKey_SummaryInputFieldPlaceholder : @"フィードバック",
                    LIFEStringKey_SummaryInputFieldDetailedPlaceholder : @"こちらに入力したテキストはバグ報告と一緒に送信されます。",
                    LIFEStringKey_StepsToReproduce : @"再現ステップ",
                    LIFEStringKey_ExpectedResults : @"予想していた結果",
                    LIFEStringKey_ExpectedResultsPlaceholder : @"どうなると予測していたのか説明してください。",
                    LIFEStringKey_ActualResults : @"実際の結果",
                    LIFEStringKey_ActualResultsPlaceholder : @"実際に起こったことを説明してください。",
                    LIFEStringKey_PoweredByBuglife : @"開発元： Buglife",
                    LIFEStringKey_HideUntilNextLaunch : @"次回起動まで隠す",
                    LIFEStringKey_DontAskUntilNextLaunch : @"次回起動まで再表示しない",
                    LIFEStringKey_HelpUsMakeXYZBetter : @"%@ の改善にご協力ください！",
                    LIFEStringKey_HelpUsMakeThisAppBetter : @"このアプリの改善にご協力ください！",
                    LIFEStringKey_ThanksForFilingABug : @"フィードバックをありがとうございます！",
                    LIFEStringKey_AttachPhoto : @"写真を添付",
                    LIFEStringKey_Arrow : @"矢印",
                    LIFEStringKey_ArrowAccessibilityValue : @"先端はトップから %.0f ピクセル、左端から %.0f ピクセルです",
                    LIFEStringKey_Blur : @"ぼかし",
                    LIFEStringKey_Loupe : @"虫眼鏡",
                    LIFEStringKey_LoupeAccessibilityLabel : @"虫眼鏡",
                    LIFEStringKey_LoupeAccessibilityValue : @"中心はピクセル座標（%.0f, %.0f）、横 %.0f ピクセル、縦 %.0f ピクセル",
                    LIFEStringKey_Component : @"コンポーネント",
                    LIFEStringKey_DiscardReportAlertTitle : @"このフィードバックを破棄？",
                    LIFEStringKey_DiscardReportAlertMessage : @"このレポートに関する全データが破棄されます…またいつでもフィードバックはすることができますので、よろしくお願いします！",
                    LIFEStringKey_DiscardReportAlertConfirm : @"破棄",
                    LIFEStringKey_DiscardReportAlertCancel : @"注意",
                    LIFEStringKey_SummaryInputFieldPlaceholder : @"報告の概要を説明してください。",
                    LIFEStringKey_Attachments : @"添付ファイル",
                    LIFEStringKey_GenericAlertTitle : @"おっと！　",
                    LIFEStringKey_InvalidEmailAlertMessage : @"%@ は有効なメールアドレスではありません。",
                    LIFEStringKey_ReportSubmissionErrorAlertTitle : @"フィードバックを送信できませんでした。",
                    LIFEStringKey_ReportSubmissionErrorAlertMessage : @"ネットワークの接続状況に不具合が発生しているのかもしれません。再度お試しください。",
                    
                    LIFEStringKey_ArrowToolLabel : @"ポイント",
                    LIFEStringKey_LoupeToolLabel : @"ズーム",
                    LIFEStringKey_BlurToolLabel : @"ぼかし",
                    LIFEStringKey_SummaryInputFieldAccessibilityHint : @"ここに入力したテキストがフィードバックともに送信されます。",
                    LIFEStringKey_ReportABugWithScreenRecording : @"スクリーン記録とともにフィードバックを送信しますか？",
                    };
    });
    
    NSString *result = strings[key];
    
    if (result == nil) {
        result = key;
    }
    
    return result;
}

#pragma mark - Korean

- (NSString *)_koreanStringForKey:(NSString *)key
{
    static NSDictionary *strings;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        strings = @{
                    LIFEStringKey_Cancel : @"취소",
                    LIFEStringKey_OK : @"확인",
                    LIFEStringKey_Done : @"완료",
                    LIFEStringKey_Next : @"다음",
                    LIFEStringKey_ReportABug : @"의견 전송",
                    LIFEStringKey_Delete : @"삭제",
                    LIFEStringKey_DeleteArrow : @"화살표 삭제",
                    LIFEStringKey_DeleteBlur : @"블러 삭제",
                    LIFEStringKey_DeleteLoupe : @"돋보기 삭제",
                    LIFEStringKey_Report : @"의견",
                    LIFEStringKey_UserEmailInputFieldTitle : @"이메일 주소",
                    LIFEStringKey_SummaryInputFieldTitle : @"의견",
                    LIFEStringKey_SummaryInputFieldDetailedTitle : @"어떤 상황인가요?",
                    LIFEStringKey_SummaryInputFieldPlaceholder : @"의견",
                    LIFEStringKey_SummaryInputFieldDetailedPlaceholder : @"여기에 입력한 내용은 버그 보고서와 함께 전송됩니다.",
                    LIFEStringKey_StepsToReproduce : @"버그 재현 방법",
                    LIFEStringKey_ExpectedResults : @"예상 결과",
                    LIFEStringKey_ExpectedResultsPlaceholder : @"예상한 결과가 무엇인지 설명해주세요.",
                    LIFEStringKey_ActualResults : @"실제 결과",
                    LIFEStringKey_ActualResultsPlaceholder : @"실제 발생한 결과를 설명해주세요.",
                    LIFEStringKey_PoweredByBuglife : @"Buglife 제공",
                    LIFEStringKey_HideUntilNextLaunch : @"다음 실행까지 숨김",
                    LIFEStringKey_DontAskUntilNextLaunch : @"다음 실행까지 묻지 않기",
                    LIFEStringKey_HelpUsMakeXYZBetter : @"%@ 서비스 개선에 참여해주세요!",
                    LIFEStringKey_HelpUsMakeThisAppBetter : @"앱 기능 개선에 참여해주세요!",
                    LIFEStringKey_ThanksForFilingABug : @"의견을 보내주셔서 감사합니다!",
                    LIFEStringKey_AttachPhoto : @"사진 첨부",
                    LIFEStringKey_Arrow : @"화살표",
                    LIFEStringKey_ArrowAccessibilityValue : @"머리 부분이 위에서 %.0f 픽셀, 왼쪽에서 %.0f 픽셀을 가리키는 중입니다",
                    LIFEStringKey_Blur : @"블러",
                    LIFEStringKey_Loupe : @"돋보기",
                    LIFEStringKey_LoupeAccessibilityLabel : @"돋보기",
                    LIFEStringKey_LoupeAccessibilityValue : @"가로 %.0f, 세로 %.0f 픽셀 좌표를 중심으로 가로 %.0f 픽셀, 세로 %.0f 픽셀 크기입니다",
                    LIFEStringKey_Component : @"구성요소",
                    LIFEStringKey_DiscardReportAlertTitle : @"작성 중인 의견을 취소할까요?",
                    LIFEStringKey_DiscardReportAlertMessage : @"지금까지 보고서에 저장한 모든 내용이 삭제됩니다. 하지만 나중에 의견을 다시 작성할 수 있습니다!",
                    LIFEStringKey_DiscardReportAlertConfirm : @"삭제",
                    LIFEStringKey_DiscardReportAlertCancel : @"취소",
                    LIFEStringKey_SummaryInputFieldPlaceholder : @"보고서 내용을 요약해주세요.",
                    LIFEStringKey_Attachments : @"첨부파일",
                    LIFEStringKey_GenericAlertTitle : @"오류!",
                    LIFEStringKey_InvalidEmailAlertMessage : @"%@ 이메일 주소는 올바르지 않습니다.",
                    LIFEStringKey_ReportSubmissionErrorAlertTitle : @"의견을 전송하는 데 실패했습니다.",
                    LIFEStringKey_ReportSubmissionErrorAlertMessage : @"네트워크 상태에 문제가 있을 수 있습니다. 확인 후 다시 시도하세요.",
                    
                    LIFEStringKey_ArrowToolLabel : @"가리키기",
                    LIFEStringKey_LoupeToolLabel : @"확대/축소",
                    LIFEStringKey_BlurToolLabel : @"블러",
                    LIFEStringKey_SummaryInputFieldAccessibilityHint : @"이곳에 입력하는 내용이 의견과 함께 전달됩니다.",
                    LIFEStringKey_ReportABugWithScreenRecording : @"화면 녹화와 함께 의견을 전송할까요?",
                    };
    });
    
    NSString *result = strings[key];
    
    if (result == nil) {
        result = key;
    }
    
    return result;
}

#pragma mark - Russian

- (NSString *)_russianStringForKey:(NSString *)key
{
    static NSDictionary *strings;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        strings = @{
                    LIFEStringKey_Cancel : @"Отмена",
                    LIFEStringKey_OK : @"ОК",
                    LIFEStringKey_Done : @"Готово",
                    LIFEStringKey_Next : @"Далее",
                    LIFEStringKey_ReportABug : @"Отправить отзыв",
                    LIFEStringKey_Delete : @"Удалить",
                    LIFEStringKey_DeleteArrow : @"Удалить стрелку",
                    LIFEStringKey_DeleteBlur : @"Удалить размытие",
                    LIFEStringKey_DeleteLoupe : @"Удалить увеличение",
                    LIFEStringKey_Report : @"Отзыв",
                    LIFEStringKey_UserEmailInputFieldTitle : @"Ваш эл. адрес",
                    LIFEStringKey_SummaryInputFieldTitle : @"Отзыв",
                    LIFEStringKey_SummaryInputFieldDetailedTitle : @"Что случилось?",
                    LIFEStringKey_SummaryInputFieldPlaceholder : @"Отзыв",
                    LIFEStringKey_SummaryInputFieldDetailedPlaceholder : @"Введите текст, который войдет в отчет об ошибках.",
                    LIFEStringKey_StepsToReproduce : @"Как воспроизвести",
                    LIFEStringKey_ExpectedResults : @"Ожидаемый результат",
                    LIFEStringKey_ExpectedResultsPlaceholder : @"Опишите, что должно было произойти.",
                    LIFEStringKey_ActualResults : @"Фактический результат",
                    LIFEStringKey_ActualResultsPlaceholder : @"Опишите, что произошло.",
                    LIFEStringKey_PoweredByBuglife : @"На платформе Buglife",
                    LIFEStringKey_HideUntilNextLaunch : @"Скрыть до следующего запуска",
                    LIFEStringKey_DontAskUntilNextLaunch : @"Не спрашивать до следующего запуска",
                    LIFEStringKey_HelpUsMakeXYZBetter : @"Помогите нам улучшить %@!",
                    LIFEStringKey_HelpUsMakeThisAppBetter : @"Спасибо, что помогаете улучшить это приложение!",
                    LIFEStringKey_ThanksForFilingABug : @"Благодарим за отправленный отзыв!",
                    LIFEStringKey_AttachPhoto : @"Прикрепить фото",
                    LIFEStringKey_Arrow : @"Стрелка",
                    LIFEStringKey_ArrowAccessibilityValue : @"Острие указывает на %.0f пикс. сверху и %.0f пикс. слева",
                    LIFEStringKey_Blur : @"Размытие",
                    LIFEStringKey_Loupe : @"Увелич. стекло",
                    LIFEStringKey_LoupeAccessibilityLabel : @"Увелич. стекло",
                    LIFEStringKey_LoupeAccessibilityValue : @"Центрирование по координатам %.0f х %.0f пикс., %.0f пикс. в ширину и %.0f пикс. в высоту",
                    LIFEStringKey_Component : @"Компонент",
                    LIFEStringKey_DiscardReportAlertTitle : @"Отменить этот отзыв?",
                    LIFEStringKey_DiscardReportAlertMessage : @"Все данные в этом отзыве будут удалены... Но вы всегда можете отправить другой отзыв позже!",
                    LIFEStringKey_DiscardReportAlertConfirm : @"Удалить",
                    LIFEStringKey_DiscardReportAlertCancel : @"Отмена",
                    LIFEStringKey_SummaryInputFieldPlaceholder : @"Кратко опишите свой отчет.",
                    LIFEStringKey_Attachments : @"Вложения",
                    LIFEStringKey_GenericAlertTitle : @"Ошибка!",
                    LIFEStringKey_InvalidEmailAlertMessage : @"Электронный адрес %@ недействителен.",
                    LIFEStringKey_ReportSubmissionErrorAlertTitle : @"Не удалось отправить ваш отзыв.",
                    LIFEStringKey_ReportSubmissionErrorAlertMessage : @"Возможно, проблема в плохом подключении к сети. Повторите попытку.",
                    
                    LIFEStringKey_ArrowToolLabel : @"Точка",
                    LIFEStringKey_LoupeToolLabel : @"Масштаб",
                    LIFEStringKey_BlurToolLabel : @"Размытие",
                    LIFEStringKey_SummaryInputFieldAccessibilityHint : @"Указанный здесь текст будет отправлен с отзывом.",
                    LIFEStringKey_ReportABugWithScreenRecording : @"Отправить отзыв с этой записью экранов?",
                    };
    });
    
    NSString *result = strings[key];
    
    if (result == nil) {
        result = key;
    }
    
    return result;
}

#pragma mark - Vietnamese

- (NSString *)_vietnameseStringForKey:(NSString *)key
{
    static NSDictionary *strings;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        strings = @{
                    LIFEStringKey_Cancel : @"Hủy",
                    LIFEStringKey_OK : @"Đồng ý",
                    LIFEStringKey_Done : @"Xong",
                    LIFEStringKey_Next : @"Tiếp",
                    LIFEStringKey_ReportABug : @"Gửi Phản hồi",
                    LIFEStringKey_Delete : @"Xóa",
                    LIFEStringKey_DeleteArrow : @"Xóa Mũi tên",
                    LIFEStringKey_DeleteBlur : @"Xóa Làm mờ",
                    LIFEStringKey_DeleteLoupe : @"Xóa Kính lúp",
                    LIFEStringKey_Report : @"Phản hồi",
                    LIFEStringKey_UserEmailInputFieldTitle : @"Email của bạn",
                    LIFEStringKey_SummaryInputFieldTitle : @"Phản hồi",
                    LIFEStringKey_SummaryInputFieldDetailedTitle : @"Chuyện gì đã xảy ra?",
                    LIFEStringKey_SummaryInputFieldPlaceholder : @"Phản hồi",
                    LIFEStringKey_SummaryInputFieldDetailedPlaceholder : @"Nội dung được nhập vào đây sẽ được gửi cùng với báo cáo lỗi.",
                    LIFEStringKey_StepsToReproduce : @"Các bước để Tái hiện lỗi",
                    LIFEStringKey_ExpectedResults : @"Kết quả Mong đợi",
                    LIFEStringKey_ExpectedResultsPlaceholder : @"Mô tả những gì bạn mong đợi sẽ xảy ra.",
                    LIFEStringKey_ActualResults : @"Kết quả Thực tế",
                    LIFEStringKey_ActualResultsPlaceholder : @"Mô tả những gì đã xảy ra trên thực tế.",
                    LIFEStringKey_PoweredByBuglife : @"Được tài trợ bởi Buglife",
                    LIFEStringKey_HideUntilNextLaunch : @"Ẩn cho tới lần khởi chạy tiếp theo",
                    LIFEStringKey_DontAskUntilNextLaunch : @"Đừng hỏi cho tới lần khởi chạy tiếp theo",
                    LIFEStringKey_HelpUsMakeXYZBetter : @"Giúp chúng tôi làm cho %@ tốt hơn!",
                    LIFEStringKey_HelpUsMakeThisAppBetter : @"Giúp chúng tôi làm cho ứng dụng này tốt hơn!",
                    LIFEStringKey_ThanksForFilingABug : @"Cám ơn bạn đã gửi cho chúng tôi phản hồi!",
                    LIFEStringKey_AttachPhoto : @"Đính kèm Ảnh",
                    LIFEStringKey_Arrow : @"Mũi tên",
                    LIFEStringKey_ArrowAccessibilityValue : @"Phần đầu chếch %.0f pixel từ phía đỉnh và %.0f pixel từ phía bên trái",
                    LIFEStringKey_Blur : @"Làm mờ",
                    LIFEStringKey_Loupe : @"Kính lúp phóng đại",
                    LIFEStringKey_LoupeAccessibilityLabel : @"Kính lúp phóng đại",
                    LIFEStringKey_LoupeAccessibilityValue : @"Được đặt vào giữa ở tọa độ pixel %.0f x %.0f, và rộng %.0f pixel x cao %.0f pixel",
                    LIFEStringKey_Component : @"Thành phần",
                    LIFEStringKey_DiscardReportAlertTitle : @"Hủy phản hồi này?",
                    LIFEStringKey_DiscardReportAlertMessage : @"Tất cả dữ liệu cho báo cáo này sẽ bị hủy... Nhưng bạn luôn có thể báo cáo phản hồi sau!",
                    LIFEStringKey_DiscardReportAlertConfirm : @"Hủy",
                    LIFEStringKey_DiscardReportAlertCancel : @"Đừng bận tâm",
                    LIFEStringKey_SummaryInputFieldPlaceholder : @"Cung cấp tóm tắt báo cáo của bạn.",
                    LIFEStringKey_Attachments : @"Tập tin đính kèm",
                    LIFEStringKey_GenericAlertTitle : @"Rất tiếc!",
                    LIFEStringKey_InvalidEmailAlertMessage : @"%@ không phải là địa chỉ email hợp lệ.",
                    LIFEStringKey_ReportSubmissionErrorAlertTitle : @"Chúng tôi không thể gửi phản hồi của bạn.",
                    LIFEStringKey_ReportSubmissionErrorAlertMessage : @"Việc này có thể do kết nối mạng kém. Vui lòng thử lại.",
                    
                    LIFEStringKey_ArrowToolLabel : @"Điểm",
                    LIFEStringKey_LoupeToolLabel : @"Thu phóng",
                    LIFEStringKey_BlurToolLabel : @"Làm mờ",
                    LIFEStringKey_SummaryInputFieldAccessibilityHint : @"Nội dung đã nhập vào đây được gửi với phản hồi của bạn.",
                    LIFEStringKey_ReportABugWithScreenRecording : @"Gửi phản hồi với bản ghi màn hình đó?",
                    };
    });
    
    NSString *result = strings[key];
    
    if (result == nil) {
        result = key;
    }
    
    return result;
}

- (NSString *)_hebrewStringForKey:(NSString *)key
{
    static NSDictionary *strings;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        strings = @{
                    LIFEStringKey_Cancel : @"ביטול",
                    LIFEStringKey_OK : @"אישור",
                    LIFEStringKey_Done : @"סיום",
                    LIFEStringKey_Next : @"המשך",
                    LIFEStringKey_ReportABug : @"שלח משוב",
                    LIFEStringKey_Delete : @"מחקו",
                    LIFEStringKey_DeleteArrow : @"מחקו חץ",
                    LIFEStringKey_DeleteBlur : @"מחקו טשטוש",
                    LIFEStringKey_DeleteLoupe : @"מחקו זכוכית מגדלת",
                    LIFEStringKey_Report : @"משוב",
                    LIFEStringKey_UserEmailInputFieldTitle : @"האימייל שלך",
                    LIFEStringKey_SummaryInputFieldTitle : @"משוב",
                    LIFEStringKey_SummaryInputFieldDetailedTitle : @"מה קרה?",
                    LIFEStringKey_SummaryInputFieldPlaceholder : @"משוב",
                    LIFEStringKey_SummaryInputFieldDetailedPlaceholder : @"טקסט שתכתבו כאן יכלל בדיווח",
                    LIFEStringKey_StepsToReproduce : @"צעדים לשחזור",
                    LIFEStringKey_ExpectedResults : @"תוצאות מצופות",
                    LIFEStringKey_ExpectedResultsPlaceholder : @"תארו מה ציפיתם שיקרה",
                    LIFEStringKey_ActualResults : @"התוצאות בפועל",
                    LIFEStringKey_ActualResultsPlaceholder : @"תארו מה קרה בפועל",
                    LIFEStringKey_PoweredByBuglife : @"Powered by Buglife",
                    LIFEStringKey_HideUntilNextLaunch : @"הסתר עד להרצה הבאה",
                    LIFEStringKey_DontAskUntilNextLaunch : @"אל תשאל עד להרצה הבאה",
                    LIFEStringKey_HelpUsMakeXYZBetter : @"עזרו לנו להפוך את %@ לטובה יותר!",
                    LIFEStringKey_HelpUsMakeThisAppBetter : @"עזרו לנו לשפר את המוצר!",
                    LIFEStringKey_ThanksForFilingABug : @"תודה על משלוח המשוב!",
                    LIFEStringKey_AttachPhoto : @"צרפו תמונה",
                    LIFEStringKey_Arrow : @"חץ",
                    LIFEStringKey_ArrowAccessibilityValue : @"ראש החץ מכוון %.0f פיקסלים מהחלק העליון ו-%.0f פיקסלים מצד שמאל",
                    LIFEStringKey_Blur : @"טשטוש",
                    LIFEStringKey_Loupe : @"זכוכית מגדלת",
                    LIFEStringKey_LoupeAccessibilityLabel : @"זכוכית מגדלת",
                    LIFEStringKey_LoupeAccessibilityValue : @"ממורכז בקואורדינטות פיקסל %.0f על %.0f, ברוחב של %.0f ובגובה %.0f פיקסלים",
                    LIFEStringKey_Component : @"",
                    LIFEStringKey_DiscardReportAlertTitle : @"לבטל את המשוב?",
                    LIFEStringKey_DiscardReportAlertMessage : @"כל הנתונים המיועדים לדוח זה יבוטלו...אך תמיד ניתן לדווח את המשוב מאוחר יותר!",
                    LIFEStringKey_DiscardReportAlertConfirm : @"מחקו דיווח",
                    LIFEStringKey_DiscardReportAlertCancel : @"ביטול",
                    LIFEStringKey_SummaryInputFieldPlaceholder : @"ספק סיכום של הדוח שלך.",
                    LIFEStringKey_Attachments : @"קבצים מצורפים",
                    LIFEStringKey_GenericAlertTitle : @"אופפסס!",
                    LIFEStringKey_InvalidEmailAlertMessage : @"%@ אינה כתובת דוא\"ל חוקית.",
                    LIFEStringKey_ReportSubmissionErrorAlertTitle : @"לא הצלחנו לשלוח את המשוב שלך.",
                    LIFEStringKey_ReportSubmissionErrorAlertMessage : @"ייתכן שהסיבה לכך היא קישוריות ירודה. אנא נסה שוב.",
                    
                    LIFEStringKey_ArrowToolLabel : @"הצבע",
                    LIFEStringKey_LoupeToolLabel : @"שנה גודל תצוגה",
                    LIFEStringKey_BlurToolLabel : @"טשטוש",
                    LIFEStringKey_SummaryInputFieldAccessibilityHint : @"טקסט שמוכנס כאן נשלח עם המשוב.",
                    LIFEStringKey_ReportABugWithScreenRecording : @"לשלוח משוב יחד עם צילום המסך?",
                    };
    });
    
    NSString *result = strings[key];
    
    if (result == nil) {
        result = key;
    }
    
    return result;
}

- (NSString *)_polishStringForKey:(NSString *)key
{
    static NSDictionary *strings;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        strings = @{
                    LIFEStringKey_Cancel : @"Anuluj",
                    LIFEStringKey_OK : @"OK",
                    LIFEStringKey_Done : @"Zrobione",
                    LIFEStringKey_Next : @"Dalej",
                    LIFEStringKey_ReportABug : @"Wyślij opinię",
                    LIFEStringKey_Delete : @"Usuń",
                    LIFEStringKey_DeleteArrow : @"Usuń strzałkę",
                    LIFEStringKey_DeleteBlur : @"Usuń rozmycie",
                    LIFEStringKey_DeleteLoupe : @"Usuń lupę",
                    LIFEStringKey_Report : @"Opinia",
                    LIFEStringKey_UserEmailInputFieldTitle : @"Twój adres e-mail",
                    LIFEStringKey_SummaryInputFieldTitle : @"Opinia",
                    LIFEStringKey_SummaryInputFieldDetailedTitle : @"Co się stało?",
                    LIFEStringKey_SummaryInputFieldPlaceholder : @"Opinia",
                    LIFEStringKey_SummaryInputFieldDetailedPlaceholder : @"Wpisana tutaj treść zostanie przekazana razem z raportem o błędzie.",
                    LIFEStringKey_StepsToReproduce : @"Kroki potrzebne do odtworzenia",
                    LIFEStringKey_ExpectedResults : @"Oczekiwane wyniki",
                    LIFEStringKey_ExpectedResultsPlaceholder : @"Opisz, co według Ciebie powinno się stać.",
                    LIFEStringKey_ActualResults : @"Rzeczywiste wyniki",
                    LIFEStringKey_ActualResultsPlaceholder : @"Opisz, co się stało.",
                    LIFEStringKey_PoweredByBuglife : @"Obsługiwane przez Buglife",
                    LIFEStringKey_HideUntilNextLaunch : @"Ukryj aż do następnej wersji",
                    LIFEStringKey_DontAskUntilNextLaunch : @"Nie pytaj aż do następnej wersji",
                    LIFEStringKey_HelpUsMakeXYZBetter : @"Pomóż nam ulepszać aplikację %@!",
                    LIFEStringKey_HelpUsMakeThisAppBetter : @"Pomóż nam ulepszać tę aplikację!",
                    LIFEStringKey_ThanksForFilingABug : @"Dziękujemy za przesłanie opinii!",
                    LIFEStringKey_AttachPhoto : @"Dołącz zdjęcie",
                    LIFEStringKey_Arrow : @"Strzałka",
                    LIFEStringKey_ArrowAccessibilityValue : @"Wskazuje %.0f piks. od góry i %.0f od lewej",
                    LIFEStringKey_Blur : @"Rozmycie",
                    LIFEStringKey_Loupe : @"Powiększenie",
                    LIFEStringKey_LoupeAccessibilityLabel : @"Powiększenie",
                    LIFEStringKey_LoupeAccessibilityValue : @"Usytuowanie: %.0f na %.0f, szerokość: %.0f piks., wysokość: %.0f piks.",
                    LIFEStringKey_Component : @"Składnik",
                    LIFEStringKey_DiscardReportAlertTitle : @"Odrzucić tę opinię?",
                    LIFEStringKey_DiscardReportAlertMessage : @"Wszystkie dane z tego raportu zostaną odrzucone... Ale możesz przesłać swoją opinię później.",
                    LIFEStringKey_DiscardReportAlertConfirm : @"Odrzuć",
                    LIFEStringKey_DiscardReportAlertCancel : @"Nieważne",
                    LIFEStringKey_SummaryInputFieldPlaceholder : @"Podaj krótki opis raportu.",
                    LIFEStringKey_Attachments : @"Załączniki",
                    LIFEStringKey_GenericAlertTitle : @"Ups!",
                    LIFEStringKey_InvalidEmailAlertMessage : @"%@ to nieprawidłowy adres e-mail.",
                    LIFEStringKey_ReportSubmissionErrorAlertTitle : @"Nie udało się przesłać Twojej opinii.",
                    LIFEStringKey_ReportSubmissionErrorAlertMessage : @"Może to być spowodowane słabym połączeniem sieciowym. Spróbuj ponownie. ",
                    
                    LIFEStringKey_ArrowToolLabel : @"Wskaż",
                    LIFEStringKey_LoupeToolLabel : @"Powiększ",
                    LIFEStringKey_BlurToolLabel : @"Rozmycie",
                    LIFEStringKey_SummaryInputFieldAccessibilityHint : @"Wpisany tu tekst zostanie przesłany razem z Twoją opinią.",
                    LIFEStringKey_ReportABugWithScreenRecording : @"Przesłać opinię z tym nagraniem ekranu?",
                    };
    });
    
    NSString *result = strings[key];
    
    if (result == nil) {
        result = key;
    }
    
    return result;
}

- (NSString *)_swedishStringForKey:(NSString *)key
{
    static NSDictionary *strings;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        strings = @{
                    LIFEStringKey_Cancel : @"Avbryt",
                    LIFEStringKey_OK : @"OK",
                    LIFEStringKey_Done : @"Klar",
                    LIFEStringKey_Next : @"Nästa",
                    LIFEStringKey_ReportABug : @"Skicka feedback",
                    LIFEStringKey_Delete : @"Ta bort",
                    LIFEStringKey_DeleteArrow : @"Ta bort pil",
                    LIFEStringKey_DeleteBlur : @"Ta bort suddighet",
                    LIFEStringKey_DeleteLoupe : @"Ta bort förstoringsglas",
                    LIFEStringKey_Report : @"Feedback",
                    LIFEStringKey_UserEmailInputFieldTitle : @"Din e-postadress",
                    LIFEStringKey_SummaryInputFieldTitle : @"Feedback",
                    LIFEStringKey_SummaryInputFieldDetailedTitle : @"Vad hände?",
                    LIFEStringKey_SummaryInputFieldPlaceholder : @"Feedback",
                    LIFEStringKey_SummaryInputFieldDetailedPlaceholder : @"Den text som skrivs här skickas som en del av buggrapporten.",
                    LIFEStringKey_StepsToReproduce : @"Steg för att återskapa",
                    LIFEStringKey_ExpectedResults : @"Förväntat resultat",
                    LIFEStringKey_ExpectedResultsPlaceholder : @"Beskriv vad du trodde skulle hända.",
                    LIFEStringKey_ActualResults : @"Verkligt resultat",
                    LIFEStringKey_ActualResultsPlaceholder : @"Beskriv vad som i själva verket hände.",
                    LIFEStringKey_PoweredByBuglife : @"Presenteras av Buglife",
                    LIFEStringKey_HideUntilNextLaunch : @"Göm tills nästa start",
                    LIFEStringKey_DontAskUntilNextLaunch : @"Fråga inte förrän appen startas igen",
                    LIFEStringKey_HelpUsMakeXYZBetter : @"Hjälp oss göra %@ bättre!",
                    LIFEStringKey_HelpUsMakeThisAppBetter : @"Hjälp oss göra denna app bättre!",
                    LIFEStringKey_ThanksForFilingABug : @"Tack för att du skickade oss dina synpunkter!",
                    LIFEStringKey_AttachPhoto : @"Bifoga foto",
                    LIFEStringKey_Arrow : @"Pil",
                    LIFEStringKey_ArrowAccessibilityValue : @"Spetsen pekar %.0f pixlar från toppen och %.0f pixlar från vänster",
                    LIFEStringKey_Blur : @"Suddighet",
                    LIFEStringKey_Loupe : @"Förstoringsglas",
                    LIFEStringKey_LoupeAccessibilityLabel : @"Förstoringsglas",
                    LIFEStringKey_LoupeAccessibilityValue : @"Centrerat på pixelkoordinater (%.0f , %.0f) med bredd %.0f pixlar och höjd %.0f pixlar.",
                    LIFEStringKey_Component : @"Komponent",
                    LIFEStringKey_DiscardReportAlertTitle : @"Radera denna feedback?",
                    LIFEStringKey_DiscardReportAlertMessage : @"All information i denna rapport kommer att raderas… men du kan alltid skicka dina synpunkter senare!",
                    LIFEStringKey_DiscardReportAlertConfirm : @"Radera",
                    LIFEStringKey_DiscardReportAlertCancel : @"Ångra",
                    LIFEStringKey_SummaryInputFieldPlaceholder : @"Sammanfatta din buggrapport. ",
                    LIFEStringKey_Attachments : @"Bilagor",
                    LIFEStringKey_GenericAlertTitle : @"Hoppsan!",
                    LIFEStringKey_InvalidEmailAlertMessage : @"%@ är inte en giltig e-postadress.",
                    LIFEStringKey_ReportSubmissionErrorAlertTitle : @"Vi kunde inte skicka din feedback.",
                    LIFEStringKey_ReportSubmissionErrorAlertMessage : @"Detta kan bero på dålig nätverksanslutning. Vänligen försök igen.",
                    
                    LIFEStringKey_ArrowToolLabel : @"Peka",
                    LIFEStringKey_LoupeToolLabel : @"Zooma",
                    LIFEStringKey_BlurToolLabel : @"Suddighet",
                    LIFEStringKey_SummaryInputFieldAccessibilityHint : @"Text som matas in här skickas tillsammans med din feedback. ",
                    LIFEStringKey_ReportABugWithScreenRecording : @"Skicka feedback med den skärminspelningen?",
                    };
    });
    
    NSString *result = strings[key];
    
    if (result == nil) {
        result = key;
    }
    
    return result;
}

- (NSString *)_italianStringForKey:(NSString *)key
{
    static NSDictionary *strings;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        strings = @{
                    LIFEStringKey_Cancel : @"Annulla",
                    LIFEStringKey_OK : @"OK",
                    LIFEStringKey_Done : @"Fine",
                    LIFEStringKey_Next : @"Avanti",
                    LIFEStringKey_ReportABug : @"Invia feedback",
                    LIFEStringKey_Delete : @"Elimina",
                    LIFEStringKey_DeleteArrow : @"Elimina freccia",
                    LIFEStringKey_DeleteBlur : @"Elimina sfocatura",
                    LIFEStringKey_DeleteLoupe : @"Elimina lente",
                    LIFEStringKey_Report : @"Feedback",
                    LIFEStringKey_UserEmailInputFieldTitle : @"Il tuo indirizzo e-mail",
                    LIFEStringKey_SummaryInputFieldTitle : @"Feedback",
                    LIFEStringKey_SummaryInputFieldDetailedTitle : @"Cosa è successo?",
                    LIFEStringKey_SummaryInputFieldPlaceholder : @"Feedback",
                    LIFEStringKey_SummaryInputFieldDetailedPlaceholder : @"Il testo inserito qui viene inviato insieme alla segnalazione di bug.",
                    LIFEStringKey_StepsToReproduce : @"Passaggi da riprodurre",
                    LIFEStringKey_ExpectedResults : @"Risultati previsti",
                    LIFEStringKey_ExpectedResultsPlaceholder : @"Descrivi il risultato previsto.",
                    LIFEStringKey_ActualResults : @"Risultati effettivi",
                    LIFEStringKey_ActualResultsPlaceholder : @"Descrivi quello che è successo in realtà.",
                    LIFEStringKey_PoweredByBuglife : @"Powered by Buglife",
                    LIFEStringKey_HideUntilNextLaunch : @"Nascondi fino al prossimo avvio",
                    LIFEStringKey_DontAskUntilNextLaunch : @"Non chiedere fino al prossimo avvio",
                    LIFEStringKey_HelpUsMakeXYZBetter : @"Aiutaci a migliorare %@!",
                    LIFEStringKey_HelpUsMakeThisAppBetter : @"Aiutaci a migliorare questa app!",
                    LIFEStringKey_ThanksForFilingABug : @"Grazie per averci inviato un feedback!",
                    LIFEStringKey_AttachPhoto : @"Allega foto",
                    LIFEStringKey_Arrow : @"Freccia",
                    LIFEStringKey_ArrowAccessibilityValue : @"La testa della freccia è posizionata a %.0f pixel dall'alto e a %.0f pixel da sinistra",
                    LIFEStringKey_Blur : @"Sfoca",
                    LIFEStringKey_Loupe : @"Lente d'ingrandimento",
                    LIFEStringKey_LoupeAccessibilityLabel : @"Lente d'ingrandimento",
                    LIFEStringKey_LoupeAccessibilityValue : @"Centrata alle coordinate pixel %.0f per %.0f, con larghezza pari a %.0f pixel per %.0f pixel di altezza",
                    LIFEStringKey_Component : @"Componente",
                    LIFEStringKey_DiscardReportAlertTitle : @"Eliminare questo feedback?",
                    LIFEStringKey_DiscardReportAlertMessage : @"Tutti i dati di questa segnalazione verranno eliminati... Ma sarà sempre possibile inviare altro feedback più tardi.",
                    LIFEStringKey_DiscardReportAlertConfirm : @"Rimuovi",
                    LIFEStringKey_DiscardReportAlertCancel : @"Non importa",
                    LIFEStringKey_SummaryInputFieldPlaceholder : @"Fornisce un riassunto del report.",
                    LIFEStringKey_Attachments : @"Allegati",
                    LIFEStringKey_GenericAlertTitle : @"Ops!",
                    LIFEStringKey_InvalidEmailAlertMessage : @"%@ non è un indirizzo e-mail valido.",
                    LIFEStringKey_ReportSubmissionErrorAlertTitle : @"Impossibile inviare il feedback.",
                    LIFEStringKey_ReportSubmissionErrorAlertMessage : @"Potrebbe essere dovuto alla scarsa connessione di rete. Riprovare.",
                    
                    LIFEStringKey_ArrowToolLabel : @"Punta",
                    LIFEStringKey_LoupeToolLabel : @"Usa zoom",
                    LIFEStringKey_BlurToolLabel : @"Sfoca",
                    LIFEStringKey_SummaryInputFieldAccessibilityHint : @"Il testo inserito qui viene inviato insieme al feedback.",
                    LIFEStringKey_ReportABugWithScreenRecording : @"Inviare il feedback con quel video?",
                    };
    });
    
    NSString *result = strings[key];
    
    if (result == nil) {
        result = key;
    }
    
    return result;
}

- (NSString *)_portugueseStringForKey:(NSString *)key
{
    static NSDictionary *strings;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        strings = @{
                    LIFEStringKey_Cancel : @"Cancelar",
                    LIFEStringKey_OK : @"OK",
                    LIFEStringKey_Done : @"Concluído",
                    LIFEStringKey_Next : @"Seguinte",
                    LIFEStringKey_ReportABug : @"Enviar comentários",
                    LIFEStringKey_Delete : @"Eliminar",
                    LIFEStringKey_DeleteArrow : @"Eliminar Seta",
                    LIFEStringKey_DeleteBlur : @"Eliminar Mancha",
                    LIFEStringKey_DeleteLoupe : @"Eliminar Lupa",
                    LIFEStringKey_Report : @"Comentários",
                    LIFEStringKey_UserEmailInputFieldTitle : @"O seu e-mail",
                    LIFEStringKey_SummaryInputFieldTitle : @"Comentários",
                    LIFEStringKey_SummaryInputFieldDetailedTitle : @"O que aconteceu?",
                    LIFEStringKey_SummaryInputFieldPlaceholder : @"Comentários",
                    LIFEStringKey_SummaryInputFieldDetailedPlaceholder : @"O texto aqui introduzido é submetido com o relatório de erro.",
                    LIFEStringKey_StepsToReproduce : @"Passos de Reprodução",
                    LIFEStringKey_ExpectedResults : @"Resultados Esperados",
                    LIFEStringKey_ExpectedResultsPlaceholder : @"Descreva o que esperava que acontecesse.",
                    LIFEStringKey_ActualResults : @"Resultados Reais",
                    LIFEStringKey_ActualResultsPlaceholder : @"Descreva o que aconteceu realmente.",
                    LIFEStringKey_PoweredByBuglife : @"Com tecnologia Buglife",
                    LIFEStringKey_HideUntilNextLaunch : @"Ocultar até à próxima execução",
                    LIFEStringKey_DontAskUntilNextLaunch : @"Não perguntar até à próxima execução",
                    LIFEStringKey_HelpUsMakeXYZBetter : @"Ajude-nos a melhorar o %@!",
                    LIFEStringKey_HelpUsMakeThisAppBetter : @"Ajude-nos a melhorar a aplicação!",
                    LIFEStringKey_ThanksForFilingABug : @"Agradecemos os comentários enviados.",
                    LIFEStringKey_AttachPhoto : @"Anexar Foto",
                    LIFEStringKey_Arrow : @"Seta",
                    LIFEStringKey_ArrowAccessibilityValue : @"A cabeça aponta para %.0f pixels a contar do topo e %.0f pixels a contar da esquerda",
                    LIFEStringKey_Blur : @"Mancha",
                    LIFEStringKey_Loupe : @"Lupa de ampliação",
                    LIFEStringKey_LoupeAccessibilityLabel : @"Lupa de ampliação",
                    LIFEStringKey_LoupeAccessibilityValue : @"Centrada nas coordenadas de pixels %.0f por %.0f, com a largura de %.0f pixels e a altura de %.0f pixels",
                    LIFEStringKey_Component : @"Componente",
                    LIFEStringKey_DiscardReportAlertTitle : @"Descartar este comentário?",
                    LIFEStringKey_DiscardReportAlertMessage : @"Todos os dados deste relatório serão descartados... mas você pode enviar comentários mais tarde.",
                    LIFEStringKey_DiscardReportAlertConfirm : @"Eliminar",
                    LIFEStringKey_DiscardReportAlertCancel : @"Esquecer",
                    LIFEStringKey_SummaryInputFieldPlaceholder : @"Forneça um resumo do seu relatório.",
                    LIFEStringKey_Attachments : @"Anexos",
                    LIFEStringKey_GenericAlertTitle : @"Ups!",
                    LIFEStringKey_InvalidEmailAlertMessage : @"%@ não é um endereço de e-mail válido.",
                    LIFEStringKey_ReportSubmissionErrorAlertTitle : @"Não conseguimos enviar seus comentários.",
                    LIFEStringKey_ReportSubmissionErrorAlertMessage : @"Tal poderá dever-se à fraca conectividade de rede. Tente novamente.",
                    
                    LIFEStringKey_ArrowToolLabel : @"Apontar",
                    LIFEStringKey_LoupeToolLabel : @"Reduzir/ampliar",
                    LIFEStringKey_BlurToolLabel : @"Desfocar",
                    LIFEStringKey_SummaryInputFieldAccessibilityHint : @"O texto digitado aqui é enviado com seus comentários.",
                    LIFEStringKey_ReportABugWithScreenRecording : @"Enviar comentários com essa gravação de tela?",
                    };
    });
    
    NSString *result = strings[key];
    
    if (result == nil) {
        result = key;
    }
    
    return result;
}

- (NSString *)_arabicStringForKey:(NSString *)key
{
    static NSDictionary *strings;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        strings = @{
                    LIFEStringKey_ReportABugWithScreenRecording : @"إرسال التعليق مع تسجيل الشاشة هذا؟",
                    
                    LIFEStringKey_Cancel : @"إلغاء",
                    LIFEStringKey_OK : @"موافق",
                    LIFEStringKey_Done : @"تمّ",
                    LIFEStringKey_Next : @"التالي",
                    LIFEStringKey_ReportABug : @"إرسال تعليق",
                    
                    LIFEStringKey_ArrowToolLabel : @"نقطة",
                    LIFEStringKey_LoupeToolLabel : @"تكبير/تصغير",
                    LIFEStringKey_BlurToolLabel : @"تمويه",
                    
                    // Delete annotation
                    LIFEStringKey_Delete : @"حذف",
                    LIFEStringKey_DeleteArrow : @"حذف السهم",
                    LIFEStringKey_DeleteBlur : @"حذف التمويه",
                    LIFEStringKey_DeleteLoupe : @"حذف العدسة المكبرة",
                    
                    // This should be short so it can fit in a back button!
                    LIFEStringKey_Report : @"التعليقات",
                    LIFEStringKey_UserEmailInputFieldTitle : @"بريدك الإلكتروني",
                    LIFEStringKey_SummaryInputFieldTitle : @"التعليقات",
                    LIFEStringKey_SummaryInputFieldDetailedTitle : @"ماذا حدث؟",
                    LIFEStringKey_SummaryInputFieldPlaceholder : @"التعليقات",
                    LIFEStringKey_SummaryInputFieldDetailedPlaceholder : @"النص الذي تم إدخاله هنا مُرسل مع تقرير الخطأ في البرمجة.",
                    LIFEStringKey_SummaryInputFieldAccessibilityHint : @"النص الذي يُدخَل هنا يُرسل مع تعليقاتك.",
                    LIFEStringKey_StepsToReproduce : @"خطوات إعادة توليد الخطأ",
                    LIFEStringKey_ExpectedResults : @"النتائج المتوقعة",
                    LIFEStringKey_ExpectedResultsPlaceholder : @"صِف ما تتوقع حدوثه.",
                    LIFEStringKey_ActualResults : @"النتائج الفعلية",
                    LIFEStringKey_ActualResultsPlaceholder : @"صِف ما حدث بالفعل.",
                    LIFEStringKey_PoweredByBuglife : @"مُشغَّل بواسطة Buglife",
                    
                    // Prompt
                    LIFEStringKey_HideUntilNextLaunch : @"اخفاء حتى بدء التشغيل القادم",
                    LIFEStringKey_DontAskUntilNextLaunch : @"لا تسأل كثيرًا حتى بدء التشغيل القادم",
                    LIFEStringKey_HelpUsMakeXYZBetter : @"ساعدنا على أن نجعل %@ أفضل!",
                    LIFEStringKey_HelpUsMakeThisAppBetter : @"ساعدنا لكي نجعل هذا التطبيق أفضل!",
                    LIFEStringKey_ThanksForFilingABug : @"شكراً لإرسالك تعليقات!",
                    
                    // Attachments
                    LIFEStringKey_AttachPhoto : @"إرفاق صورة",
                    LIFEStringKey_Arrow : @"سهم",
                    LIFEStringKey_ArrowAccessibilityValue : @"الرأس تشير إلى %.0f بكسل من الأعلى وإلى %.0f  بكسل من اليسار",
                    LIFEStringKey_Blur : @"تمويه",
                    LIFEStringKey_Loupe : @"عدسة مكبرة",
                    LIFEStringKey_LoupeAccessibilityLabel : @"عدسة مكبرة",
                    LIFEStringKey_LoupeAccessibilityValue : @"المركز عند إحداثيات البكسل %.0f و %.0f، وعبارة عن %.0f بكسل عرض و%.0f بكسل ارتفاع",
                    LIFEStringKey_Component : @"مُكوِّن",
                    
                    // Discard alert
                    LIFEStringKey_DiscardReportAlertTitle : @"إزالة هذا التعليق؟",
                    LIFEStringKey_DiscardReportAlertMessage : @"سوف يتم التخلص من جميع البيانات المتعلقة بهذا التقرير... ولكن يمكنك دائمًا الإبلاغ عن تعليقات فيما بعد!",
                    LIFEStringKey_DiscardReportAlertConfirm : @"تجاهل",
                    LIFEStringKey_DiscardReportAlertCancel : @"لا يهم",
                    
                    LIFEStringKey_Attachments : @"المُرفقات",
                    LIFEStringKey_GenericAlertTitle : @"عذرًا!",
                    LIFEStringKey_InvalidEmailAlertMessage : @"%@ ليس عنوان بريد إلكتروني صالح.",
                    LIFEStringKey_ReportSubmissionErrorAlertTitle : @"لم نتمكن من إرسال تعليقك.",
                    LIFEStringKey_ReportSubmissionErrorAlertMessage : @"قد يكون هذا بسبب سوء توصيل الشبكة. يُرجى إعادة المحاولة مرة أخرى.",
                    };
    });
    
    NSString *result = strings[key];
    
    if (result == nil) {
        result = key;
    }
    
    return result;
}

@end
