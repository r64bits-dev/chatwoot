/* eslint no-plusplus: 0 */
import AvatarUploader from './widgets/forms/AvatarUploader.vue';
import Bar from './widgets/chart/BarChart';
import LineChart from './widgets/chart/LineChart';
import Button from './ui/WootButton';
import Select from './ui/WootSelect';
import Code from './Code';
import ColorPicker from './widgets/ColorPicker';
import ConfirmDeleteModal from './widgets/modal/ConfirmDeleteModal.vue';
import ConfirmModal from './widgets/modal/ConfirmationModal.vue';
import ContextMenu from './ui/ContextMenu.vue';
import DeleteModal from './widgets/modal/DeleteModal.vue';
import DropdownItem from 'shared/components/ui/dropdown/DropdownItem';
import DropdownMenu from 'shared/components/ui/dropdown/DropdownMenu';
import DivisionLine from './widgets/DivisionLine';
import FeatureToggle from './widgets/FeatureToggle';
import HorizontalBar from './widgets/chart/HorizontalBarChart';
import Input from './widgets/forms/Input.vue';
import TextArea from './widgets/forms/TextArea.vue';
import PhoneInput from './widgets/forms/PhoneInput.vue';
import Label from './ui/Label';
import LoadingState from './widgets/LoadingState';
import Modal from './Modal';
import ModalHeader from './ModalHeader';
import ReportStatsCard from './widgets/ReportStatsCard';
import SidemenuIcon from './SidemenuIcon';
import Spinner from 'shared/components/Spinner';
import SubmitButton from './buttons/FormSubmitButton';
import Tabs from './ui/Tabs/Tabs';
import TabsItem from './ui/Tabs/TabsItem';
import Thumbnail from './widgets/Thumbnail.vue';

const WootUIKit = {
  AvatarUploader,
  Bar,
  Button,
  Code,
  ColorPicker,
  Select,
  ConfirmDeleteModal,
  ConfirmModal,
  ContextMenu,
  DeleteModal,
  DivisionLine,
  DropdownItem,
  DropdownMenu,
  FeatureToggle,
  HorizontalBar,
  LineChart,
  Input,
  TextArea,
  PhoneInput,
  Label,
  LoadingState,
  Modal,
  ModalHeader,
  ReportStatsCard,
  SidemenuIcon,
  Spinner,
  SubmitButton,
  Tabs,
  TabsItem,
  Thumbnail,
  install(Vue) {
    const keys = Object.keys(this);
    keys.pop(); // remove 'install' from keys
    let i = keys.length;
    while (i--) {
      Vue.component(`woot${keys[i]}`, this[keys[i]]);
    }
  },
};

if (typeof window !== 'undefined' && window.Vue) {
  window.Vue.use(WootUIKit);
}

export default WootUIKit;
