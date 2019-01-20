<?php
/**
 * @file
 * Enables modules and site configuration for a standard site installation.
 */

use Drupal\Core\Form\FormStateInterface;
use Drupal\language\Entity\ConfigurableLanguage;
use Drupal\contact\Entity\ContactForm;

/**
 * Implements hook_form_FORM_ID_alter() for install_configure_form().
 *
 * Allows the profile to alter the site configuration form.
 */
function stratoserp_base_form_install_configure_form_alter(&$form, FormStateInterface $form_state) {
  // Add a placeholder as example that one can choose an arbitrary site name.
  $form['site_information']['site_name']['#attributes']['placeholder'] = t('My site');
  $form['#submit'][] = 'stratoserp_base_form_install_configure_submit';
}

/**
 * Submission handler to sync the contact.form.feedback recipient.
 */
function stratoserp_base_form_install_configure_submit($form, FormStateInterface $form_state) {
  $site_mail = $form_state->getValue('site_mail');
  ContactForm::load('feedback')->setRecipients([$site_mail])->trustData()->save();
}


/**
 * Implements hook_install_tasks().
 */
function stratoserp_base_install_tasks(&$install_state) {
    $myprofile_needs_batch_processing = \Drupal::state()->get('myprofile.needs_batch_processing', TRUE);
    return array(
        'stratoserp_generate_content' => array(
            'display_name' => t('Generate content'),
            'display' => TRUE,
            'type' => 'batch',
        ),
    );
}

/**
 * Batch job to configure multilingual components.
 *
 * @param array $install_state
 *   The current install state.
 *
 * @return array
 *   The batch job definition.
 */
function stratoserp_generate_content(array &$install_state) {
    $batch = array();

    //If the multiligual config checkbox were checked.
    if (isset($install_state['corporate']['enable_multilingual'])
        && $install_state['corporate']['enable_multilingual'] == TRUE) {

        //Install the Varbase internationalization feature module.
        $batch['operations'][] = ['corporate_assemble_extra_component_then_install', (array) 'corporate_internationalization'];

        //Add all selected languages and then translatvarbase_hide_messagesion
        // will fetched for theme.
        foreach ($install_state['corporate']['multilingual_languages'] as $language_code) {
            $batch['operations'][] = ['corporate_configure_language_and_fetch_traslation', (array) $language_code];
        }
        return $batch;
    }

}
